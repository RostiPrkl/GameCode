shader_type spatial;

render_mode unshaded, blend_mix;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float value_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float p00 = rand(mod(o, size));
	float p01 = rand(mod(o + vec2(0.0, 1.0), size));
	float p10 = rand(mod(o + vec2(1.0, 0.0), size));
	float p11 = rand(mod(o + vec2(1.0, 1.0), size));
	p00 = sin(p00 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p01 = sin(p01 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p10 = sin(p10 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p11 = sin(p11 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_value(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = value_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlin_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float a00 = rand(mod(o, size)) * 6.28318530718 + offset * 6.28318530718;
	float a01 = rand(mod(o + vec2(0.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a10 = rand(mod(o + vec2(1.0, 0.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a11 = rand(mod(o + vec2(1.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	vec2 v00 = vec2(cos(a00), sin(a00));
	vec2 v01 = vec2(cos(a01), sin(a01));
	vec2 v10 = vec2(cos(a10), sin(a10));
	vec2 v11 = vec2(cos(a11), sin(a11));
	float p00 = dot(v00, f);
	float p01 = dot(v01, f - vec2(0.0, 1.0));
	float p10 = dot(v10, f - vec2(1.0, 0.0));
	float p11 = dot(v11, f - vec2(1.0, 1.0));
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return 0.5 + mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_perlin(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlin_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlinabs_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	return abs(2.0*perlin_noise_2d(coord, size, offset, seed)-1.0);
}
float fbm_2d_perlinabs(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlinabs_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float fbm_2d_mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
float fbm_2d_permute(float x) {
	return fbm_2d_mod289(((x * 34.0) + 1.0) * x);
}
vec2 fbm_2d_rgrad2(vec2 p, float rot, float seed) {
	float u = fbm_2d_permute(fbm_2d_permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = fract(u) * 6.28318530718; // 2*pi
	return vec2(cos(u), sin(u));
}
float simplex_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	coord *= 2.0; // needed for it to tile
	coord += rand2(vec2(seed, 1.0-seed)) + size;
	size *= 2.0; // needed for it to tile
	coord.y += 0.001;
	vec2 uv = vec2(coord.x + coord.y*0.5, coord.y);
	vec2 i0 = floor(uv);
	vec2 f0 = fract(uv);
	vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
	vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
	vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
	i1 = i0 + i1;
	vec2 i2 = i0 + vec2(1.0, 1.0);
	vec2 d0 = coord - p0;
	vec2 d1 = coord - p1;
	vec2 d2 = coord - p2;
	vec3 xw = mod(vec3(p0.x, p1.x, p2.x), size.x);
	vec3 yw = mod(vec3(p0.y, p1.y, p2.y), size.y);
	vec3 iuw = xw + 0.5 * yw;
	vec3 ivw = yw;
	vec2 g0 = fbm_2d_rgrad2(vec2(iuw.x, ivw.x), offset, seed);
	vec2 g1 = fbm_2d_rgrad2(vec2(iuw.y, ivw.y), offset, seed);
	vec2 g2 = fbm_2d_rgrad2(vec2(iuw.z, ivw.z), offset, seed);
	vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
	vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
	t = max(t, vec3(0.0));
	vec3 t2 = t * t;
	vec3 t4 = t2 * t2;
	float n = dot(t4, w);
	return 0.5 + 5.5 * n;
}
float fbm_2d_simplex(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = simplex_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node =  0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718 * node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular2_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular2(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular2_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular3_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular3(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular3_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular4_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular4(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular4_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular5_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.5 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular5(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular5_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular6_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular6(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular6_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
// MIT License Inigo Quilez - https://www.shadertoy.com/view/Xd23Dh
float voronoise_noise_2d( vec2 coord, vec2 size, float offset, float seed) {
	vec2 i = floor(coord) + rand2(vec2(seed, 1.0-seed)) + size;
	vec2 f = fract(coord);
	
	vec2 a = vec2(0.0);
	
	for( int y=-2; y<=2; y++ ) {
		for( int x=-2; x<=2; x++ ) {
			vec2  g = vec2( float(x), float(y) );
			vec3  o = rand3( mod(i + g, size) + vec2(seed) );
			o.xy += 0.25 * sin(offset * 6.28318530718 + 6.28318530718*o.xy);
			vec2  d = g - f + o.xy;
			float w = pow( 1.0-smoothstep(0.0, 1.414, length(d)), 1.0 );
			a += vec2(o.z*w,w);
		}
	}
	
	return a.x/a.y;
}
float fbm_2d_voronoise(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = voronoise_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 aces_tonemap(vec3 color){	
	mat3 m1 = mat3(
        vec3(0.59719, 0.07600, 0.02840),
        vec3(0.35458, 0.90834, 0.13383),
        vec3(0.04823, 0.01566, 0.83777)
	);
	mat3 m2 = mat3(
        vec3(1.60475, -0.10208, -0.00327),
        vec3(-0.53108,  1.10813, -0.07276),
        vec3(-0.07367, -0.00605,  1.07602)
	);
	vec3 v = m1 * color;    
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
	return pow(clamp(m2 * (a / b), 0.0, 1.0), vec3(1.0 / 2.2));	
}
vec2 scale(vec2 uv, vec2 center, vec2 scale) {
	uv -= center;
	uv /= scale;
	uv += center;
	return uv;
}
const float p_o296000_amount1 = 1.000000000;
const float p_o295991_cx = 0.000000000;
const float p_o295991_cy = 0.000000000;
const float p_o295991_scale_x = 1.044950000;
const float p_o295991_scale_y = 1.000000000;
const float p_o295988_d_in1_x = 0.000000000;
const float p_o295988_d_in1_y = 0.000000000;
const float p_o295988_d_in1_z = 0.000000000;
const float p_o295988_d_in2_x = 1.000000000;
const float p_o295988_d_in2_y = 0.866900000;
const float p_o295988_d_in2_z = 0.810800000;
const float p_o295986_amount1 = 1.200000000;
const float p_o295982_amount1 = 0.520000000;
const float p_o295982_amount2 = 1.000000000;
const float p_o295968_gradient_0_pos = 0.000000000;
const vec4 p_o295968_gradient_0_col = vec4(0.000000000, 0.101562001, 0.092041001, 1.000000000);
const float p_o295968_gradient_1_pos = 0.455852000;
const vec4 p_o295968_gradient_1_col = vec4(0.012695000, 0.406250000, 0.258666992, 1.000000000);
const float p_o295968_gradient_2_pos = 1.000000000;
const vec4 p_o295968_gradient_2_col = vec4(0.214844003, 0.779174984, 1.000000000, 1.000000000);
vec4 o295968_gradient_gradient_fct(float x) {
  if (x < p_o295968_gradient_0_pos) {
    return p_o295968_gradient_0_col;
  } else if (x < p_o295968_gradient_1_pos) {
    return mix(p_o295968_gradient_0_col, p_o295968_gradient_1_col, ((x-p_o295968_gradient_0_pos)/(p_o295968_gradient_1_pos-p_o295968_gradient_0_pos)));
  } else if (x < p_o295968_gradient_2_pos) {
    return mix(p_o295968_gradient_1_col, p_o295968_gradient_2_col, ((x-p_o295968_gradient_1_pos)/(p_o295968_gradient_2_pos-p_o295968_gradient_1_pos)));
  }
  return p_o295968_gradient_2_col;
}
const float p_o295965_amount1 = 0.350000000;
const float p_o295965_amount2 = 0.570000000;
const float p_o295967_default_in1 = 0.000000000;
const float p_o295967_default_in2 = 2.450000000;
const float p_o295996_sigma = 20.000000000;
const float p_o295996_center_x = 0.000000000;
const float p_o295996_center_y = -0.500000000;
const float p_o295996_iter = 35.000000000;
const float p_o295987_value = 0.500000000;
const float p_o295987_width = 0.264200000;
const float p_o295987_contrast = -0.630000000;
const float p_o295966_default_in1 = 0.000000000;
const float p_o295966_default_in2 = 0.000000000;
const float p_o295943_translate_x = 0.000000000;
const float p_o295943_translate_y = 0.000000000;
const float p_o295943_rotate = 0.000000000;
const float p_o295943_scale_x = 2.000000000;
const float p_o295943_scale_y = 2.000000000;
const float p_o295952_repeat = 1.000000000;
const float p_o295952_rotate = -90.000000000;
const float p_o295952_gradient_0_pos = 0.000000000;
const vec4 p_o295952_gradient_0_col = vec4(0.578125000, 0.578125000, 0.578125000, 1.000000000);
const float p_o295952_gradient_1_pos = 1.000000000;
const vec4 p_o295952_gradient_1_col = vec4(0.949218988, 0.949218988, 0.949218988, 1.000000000);
vec4 o295952_gradient_gradient_fct(float x) {
  if (x < p_o295952_gradient_0_pos) {
    return p_o295952_gradient_0_col;
  } else if (x < p_o295952_gradient_1_pos) {
    return mix(p_o295952_gradient_0_col, p_o295952_gradient_1_col, ((x-p_o295952_gradient_0_pos)/(p_o295952_gradient_1_pos-p_o295952_gradient_0_pos)));
  }
  return p_o295952_gradient_1_col;
}
const float p_o295951_value = 0.530000000;
const float p_o295951_width = 1.000000000;
const float p_o295946_amount = 0.035000000;
const float p_o295946_eps = 0.100000000;
const float seed_o295950 = 0.086813703;
const float p_o295950_scale_x = 10.000000000;
const float p_o295950_scale_y = 10.000000000;
const float p_o295950_folds = 0.000000000;
const float p_o295950_iterations = 1.000000000;
const float p_o295950_persistence = 0.000000000;
float o295946_input_d(vec2 uv, float _seed_variation_) {
float o295950_0_1_f = fbm_2d_perlin((uv), vec2(p_o295950_scale_x, p_o295950_scale_y), int(p_o295950_folds), int(p_o295950_iterations), p_o295950_persistence, (elapsed_time*0.5), (seed_o295950+fract(_seed_variation_)));
return o295950_0_1_f;
}
vec2 o295946_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o295946_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o295946_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o295946_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o295946_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float seed_o295942 = 0.843448281;
const float p_o295942_scale_x = 10.000000000;
const float p_o295942_scale_y = 10.000000000;
const float p_o295942_folds = 0.000000000;
const float p_o295942_iterations = 2.000000000;
const float p_o295942_persistence = 0.280000000;
const float p_o295945_default_in1 = 0.000000000;
const float p_o295945_default_in2 = 0.000000000;
const float p_o295944_sides = 5.000000000;
const float p_o295944_radius = 1.873600000;
const float p_o295944_edge = 0.900000000;
vec4 o295996_input_in(vec2 uv, float _seed_variation_) {
float o295952_0_r = 0.5+(cos(p_o295952_rotate*0.01745329251)*((uv).x-0.5)+sin(p_o295952_rotate*0.01745329251)*((uv).y-0.5))/(cos(abs(mod(p_o295952_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o295952_0_1_rgba = o295952_gradient_gradient_fct(fract(o295952_0_r*p_o295952_repeat));
vec2 o295946_0_slope = o295946_slope((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295946_eps, _seed_variation_);
vec2 o295946_0_warp = o295946_0_slope;float o295942_0_1_f = fbm_2d_perlin(((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))+p_o295946_amount*o295946_0_warp), vec2(p_o295942_scale_x, p_o295942_scale_y), int(p_o295942_folds), int(p_o295942_iterations), p_o295942_persistence, (elapsed_time*0.5), (seed_o295942+fract(_seed_variation_)));
vec4 o295946_0_1_rgba = vec4(vec3(o295942_0_1_f), 1.0);
vec3 o295951_0_false = clamp((o295946_0_1_rgba.rgb-vec3(p_o295951_value))/max(0.0001, p_o295951_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o295951_0_true = vec3(1.0)-o295951_0_false;vec4 o295951_0_1_rgba = vec4(o295951_0_false, o295946_0_1_rgba.a);
vec4 o295943_0_1_rgba = o295951_0_1_rgba;
float o295944_0_1_f = shape_circle((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295944_sides, p_o295944_radius*1.0, p_o295944_edge*1.0);
float o295945_0_clamp_false = smoothstep(0.0, 1.0, o295944_0_1_f);
float o295945_0_clamp_true = clamp(o295945_0_clamp_false, 0.0, 1.0);
float o295945_0_1_f = o295945_0_clamp_false;
vec4 o295943_1_3_rgba = vec4(vec3(o295945_0_1_f), 1.0);
float o295966_0_clamp_false = (dot((o295943_0_1_rgba).rgb, vec3(1.0))/3.0)*(dot((o295943_1_3_rgba).rgb, vec3(1.0))/3.0);
float o295966_0_clamp_true = clamp(o295966_0_clamp_false, 0.0, 1.0);
float o295966_0_1_f = o295966_0_clamp_false;
float o295987_0_step = clamp((o295966_0_1_f - (p_o295987_value))/max(0.0001, p_o295987_width)+0.5, 0.0, 1.0);
float o295987_0_false = clamp((min(o295987_0_step, 1.0-o295987_0_step) * 2.0) / (1.0 - p_o295987_contrast), 0.0, 1.0);
float o295987_0_true = 1.0-o295987_0_false;float o295987_0_1_f = o295987_0_false;
return vec4(vec3(o295987_0_1_f), 1.0);
}
float o295996_input_amount(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 o295996_fct(vec2 uv, vec2 center, float _seed_variation_) {
	vec2 e = -sign(p_o295996_sigma)*normalize(uv-center)/128.000000000;
	vec4 rv = vec4(0.0);
	float sum = 0.0;
	float sigma = max(0.0000001f, abs(p_o295996_sigma))*o295996_input_amount(uv, _seed_variation_);
	for (float i = 0.0; i <= p_o295996_iter; i += 1.0) {
		float coef = exp(-0.5*(pow(i/sigma, 2.0)))/(6.28318530718*sigma*sigma);
		rv += o295996_input_in(uv+i*e, _seed_variation_)*coef;
		sum += coef;
	}
	return rv/sum;
}const float p_o295992_sigma = 4.200000000;
const float p_o295992_center_x = 0.000000000;
const float p_o295992_center_y = -0.500000000;
const float p_o295992_iter = 5.000000000;
vec4 o295992_input_in(vec2 uv, float _seed_variation_) {
float o295952_0_r = 0.5+(cos(p_o295952_rotate*0.01745329251)*((uv).x-0.5)+sin(p_o295952_rotate*0.01745329251)*((uv).y-0.5))/(cos(abs(mod(p_o295952_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o295952_0_1_rgba = o295952_gradient_gradient_fct(fract(o295952_0_r*p_o295952_repeat));
vec2 o295946_0_slope = o295946_slope((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295946_eps, _seed_variation_);
vec2 o295946_0_warp = o295946_0_slope;float o295942_0_1_f = fbm_2d_perlin(((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))+p_o295946_amount*o295946_0_warp), vec2(p_o295942_scale_x, p_o295942_scale_y), int(p_o295942_folds), int(p_o295942_iterations), p_o295942_persistence, (elapsed_time*0.5), (seed_o295942+fract(_seed_variation_)));
vec4 o295946_0_1_rgba = vec4(vec3(o295942_0_1_f), 1.0);
vec3 o295951_0_false = clamp((o295946_0_1_rgba.rgb-vec3(p_o295951_value))/max(0.0001, p_o295951_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o295951_0_true = vec3(1.0)-o295951_0_false;vec4 o295951_0_1_rgba = vec4(o295951_0_false, o295946_0_1_rgba.a);
vec4 o295943_0_1_rgba = o295951_0_1_rgba;
float o295944_0_1_f = shape_circle((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295944_sides, p_o295944_radius*1.0, p_o295944_edge*1.0);
float o295945_0_clamp_false = smoothstep(0.0, 1.0, o295944_0_1_f);
float o295945_0_clamp_true = clamp(o295945_0_clamp_false, 0.0, 1.0);
float o295945_0_1_f = o295945_0_clamp_false;
vec4 o295943_1_3_rgba = vec4(vec3(o295945_0_1_f), 1.0);
float o295966_0_clamp_false = (dot((o295943_0_1_rgba).rgb, vec3(1.0))/3.0)*(dot((o295943_1_3_rgba).rgb, vec3(1.0))/3.0);
float o295966_0_clamp_true = clamp(o295966_0_clamp_false, 0.0, 1.0);
float o295966_0_1_f = o295966_0_clamp_false;
float o295987_0_step = clamp((o295966_0_1_f - (p_o295987_value))/max(0.0001, p_o295987_width)+0.5, 0.0, 1.0);
float o295987_0_false = clamp((min(o295987_0_step, 1.0-o295987_0_step) * 2.0) / (1.0 - p_o295987_contrast), 0.0, 1.0);
float o295987_0_true = 1.0-o295987_0_false;float o295987_0_1_f = o295987_0_false;
return vec4(vec3(o295987_0_1_f), 1.0);
}
float o295992_input_amount(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 o295992_fct(vec2 uv, vec2 center, float _seed_variation_) {
	vec2 e = -sign(p_o295992_sigma)*normalize(uv-center)/128.000000000;
	vec4 rv = vec4(0.0);
	float sum = 0.0;
	float sigma = max(0.0000001f, abs(p_o295992_sigma))*o295992_input_amount(uv, _seed_variation_);
	for (float i = 0.0; i <= p_o295992_iter; i += 1.0) {
		float coef = exp(-0.5*(pow(i/sigma, 2.0)))/(6.28318530718*sigma*sigma);
		rv += o295992_input_in(uv+i*e, _seed_variation_)*coef;
		sum += coef;
	}
	return rv/sum;
}const float p_o295985_default_in1 = 0.000000000;
const float p_o295985_default_in2 = 0.000000000;
const float p_o295984_sides = 5.000000000;
const float p_o295984_radius = 1.400000000;
const float p_o295984_edge = 1.000000000;
const float p_o296001_sides = 4.000000000;
const float p_o296001_radius = 1.000000000;
const float p_o296001_edge = 0.000000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec4 o295996_0_1_rgba = o295996_fct((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), vec2(p_o295996_center_x, p_o295996_center_y)+vec2(0.5), _seed_variation_);
float o295967_0_clamp_false = (dot((o295996_0_1_rgba).rgb, vec3(1.0))/3.0)*p_o295967_default_in2;
float o295967_0_clamp_true = clamp(o295967_0_clamp_false, 0.0, 1.0);
float o295967_0_2_f = o295967_0_clamp_false;
float o295952_0_r = 0.5+(cos(p_o295952_rotate*0.01745329251)*((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))).x-0.5)+sin(p_o295952_rotate*0.01745329251)*((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))).y-0.5))/(cos(abs(mod(p_o295952_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o295952_0_1_rgba = o295952_gradient_gradient_fct(fract(o295952_0_r*p_o295952_repeat));
vec2 o295946_0_slope = o295946_slope((transform2((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295946_eps, _seed_variation_);
vec2 o295946_0_warp = o295946_0_slope;float o295942_0_1_f = fbm_2d_perlin(((transform2((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))+p_o295946_amount*o295946_0_warp), vec2(p_o295942_scale_x, p_o295942_scale_y), int(p_o295942_folds), int(p_o295942_iterations), p_o295942_persistence, (elapsed_time*0.5), (seed_o295942+fract(_seed_variation_)));
vec4 o295946_0_1_rgba = vec4(vec3(o295942_0_1_f), 1.0);
vec3 o295951_0_false = clamp((o295946_0_1_rgba.rgb-vec3(p_o295951_value))/max(0.0001, p_o295951_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o295951_0_true = vec3(1.0)-o295951_0_false;vec4 o295951_0_1_rgba = vec4(o295951_0_false, o295946_0_1_rgba.a);
vec4 o295943_0_1_rgba = o295951_0_1_rgba;
float o295944_0_1_f = shape_circle((transform2((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295944_sides, p_o295944_radius*1.0, p_o295944_edge*1.0);
float o295945_0_clamp_false = smoothstep(0.0, 1.0, o295944_0_1_f);
float o295945_0_clamp_true = clamp(o295945_0_clamp_false, 0.0, 1.0);
float o295945_0_1_f = o295945_0_clamp_false;
vec4 o295943_1_3_rgba = vec4(vec3(o295945_0_1_f), 1.0);
float o295966_0_clamp_false = (dot((o295943_0_1_rgba).rgb, vec3(1.0))/3.0)*(dot((o295943_1_3_rgba).rgb, vec3(1.0))/3.0);
float o295966_0_clamp_true = clamp(o295966_0_clamp_false, 0.0, 1.0);
float o295966_0_1_f = o295966_0_clamp_false;
vec4 o295992_0_1_rgba = o295992_fct((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), vec2(p_o295992_center_x, p_o295992_center_y)+vec2(0.5), _seed_variation_);
vec4 o295965_0_b = vec4(vec3(o295967_0_2_f), 1.0);
vec4 o295965_0_l;
float o295965_0_a;

o295965_0_l = vec4(vec3(o295966_0_1_f), 1.0);
o295965_0_a = p_o295965_amount1*1.0;
o295965_0_b = vec4(blend_normal((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), o295965_0_l.rgb, o295965_0_b.rgb, o295965_0_a*o295965_0_l.a), min(1.0, o295965_0_b.a+o295965_0_a*o295965_0_l.a));

o295965_0_l = o295992_0_1_rgba;
o295965_0_a = p_o295965_amount2*1.0;
o295965_0_b = vec4(blend_additive((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), o295965_0_l.rgb, o295965_0_b.rgb, o295965_0_a*o295965_0_l.a), min(1.0, o295965_0_b.a+o295965_0_a*o295965_0_l.a));

vec4 o295965_0_2_rgba = o295965_0_b;
vec4 o295968_0_1_rgba = o295968_gradient_gradient_fct((dot((o295965_0_2_rgba).rgb, vec3(1.0))/3.0));
float o295984_0_1_f = shape_circle((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), p_o295984_sides, p_o295984_radius*1.0, p_o295984_edge*1.0);
float o295985_0_clamp_false = smoothstep(0.0, 1.0, o295984_0_1_f);
float o295985_0_clamp_true = clamp(o295985_0_clamp_false, 0.0, 1.0);
float o295985_0_1_f = o295985_0_clamp_false;
vec4 o295982_0_b = o295968_0_1_rgba;
vec4 o295982_0_l;
float o295982_0_a;

o295982_0_l = o295943_1_3_rgba;
o295982_0_a = p_o295982_amount1*1.0;
o295982_0_b = vec4(blend_multiply((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), o295982_0_l.rgb, o295982_0_b.rgb, o295982_0_a*o295982_0_l.a), min(1.0, o295982_0_b.a+o295982_0_a*o295982_0_l.a));

o295982_0_l = vec4(vec3(o295985_0_1_f), 1.0);
o295982_0_a = p_o295982_amount2*1.0;
o295982_0_b = vec4(blend_multiply((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), o295982_0_l.rgb, o295982_0_b.rgb, o295982_0_a*o295982_0_l.a), min(1.0, o295982_0_b.a+o295982_0_a*o295982_0_l.a));

vec4 o295982_0_2_rgba = o295982_0_b;
vec4 o295986_0_b = o295982_0_2_rgba;
vec4 o295986_0_l;
float o295986_0_a;

o295986_0_l = o295982_0_2_rgba;
o295986_0_a = p_o295986_amount1*1.0;
o295986_0_b = vec4(blend_additive((scale((uv), vec2(0.5+p_o295991_cx, 0.5+p_o295991_cy), vec2(p_o295991_scale_x, p_o295991_scale_y))), o295986_0_l.rgb, o295986_0_b.rgb, o295986_0_a*o295986_0_l.a), min(1.0, o295986_0_b.a+o295986_0_a*o295986_0_l.a));

vec4 o295986_0_2_rgba = o295986_0_b;
vec3 o295988_0_clamp_false = pow(((o295986_0_2_rgba).rgb),vec3(p_o295988_d_in2_x, p_o295988_d_in2_y, p_o295988_d_in2_z));
vec3 o295988_0_clamp_true = clamp(o295988_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o295988_0_2_rgb = o295988_0_clamp_false;
vec3 o295983_0_1_rgb = aces_tonemap(o295988_0_2_rgb);
float o295989_0_1_f = vec4(o295983_0_1_rgb, 1.0).r;
vec4 o295991_0_1_rgba = vec4(vec3(o295989_0_1_f), 1.0);
vec4 o295996_0_3_rgba = o295996_fct((uv), vec2(p_o295996_center_x, p_o295996_center_y)+vec2(0.5), _seed_variation_);
float o295967_3_clamp_false = (dot((o295996_0_3_rgba).rgb, vec3(1.0))/3.0)*p_o295967_default_in2;
float o295967_3_clamp_true = clamp(o295967_3_clamp_false, 0.0, 1.0);
float o295967_0_5_f = o295967_3_clamp_false;
float o295952_2_r = 0.5+(cos(p_o295952_rotate*0.01745329251)*((uv).x-0.5)+sin(p_o295952_rotate*0.01745329251)*((uv).y-0.5))/(cos(abs(mod(p_o295952_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o295952_0_3_rgba = o295952_gradient_gradient_fct(fract(o295952_2_r*p_o295952_repeat));
vec2 o295946_2_slope = o295946_slope((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_3_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_3_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295946_eps, _seed_variation_);
vec2 o295946_2_warp = o295946_2_slope;float o295942_0_4_f = fbm_2d_perlin(((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_3_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_3_rgba).rgb, vec3(1.0))/3.0)-1.0))))+p_o295946_amount*o295946_2_warp), vec2(p_o295942_scale_x, p_o295942_scale_y), int(p_o295942_folds), int(p_o295942_iterations), p_o295942_persistence, (elapsed_time*0.5), (seed_o295942+fract(_seed_variation_)));
vec4 o295946_0_3_rgba = vec4(vec3(o295942_0_4_f), 1.0);
vec3 o295951_2_false = clamp((o295946_0_3_rgba.rgb-vec3(p_o295951_value))/max(0.0001, p_o295951_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o295951_2_true = vec3(1.0)-o295951_2_false;vec4 o295951_0_3_rgba = vec4(o295951_2_false, o295946_0_3_rgba.a);
vec4 o295943_0_5_rgba = o295951_0_3_rgba;
float o295944_0_4_f = shape_circle((transform2((uv), vec2(p_o295943_translate_x*(2.0*1.0-1.0), p_o295943_translate_y*(2.0*1.0-1.0)), p_o295943_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295943_scale_x*(2.0*(dot((o295952_0_3_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o295943_scale_y*(2.0*(dot((o295952_0_3_rgba).rgb, vec3(1.0))/3.0)-1.0)))), p_o295944_sides, p_o295944_radius*1.0, p_o295944_edge*1.0);
float o295945_2_clamp_false = smoothstep(0.0, 1.0, o295944_0_4_f);
float o295945_2_clamp_true = clamp(o295945_2_clamp_false, 0.0, 1.0);
float o295945_0_3_f = o295945_2_clamp_false;
vec4 o295943_1_7_rgba = vec4(vec3(o295945_0_3_f), 1.0);
float o295966_2_clamp_false = (dot((o295943_0_5_rgba).rgb, vec3(1.0))/3.0)*(dot((o295943_1_7_rgba).rgb, vec3(1.0))/3.0);
float o295966_2_clamp_true = clamp(o295966_2_clamp_false, 0.0, 1.0);
float o295966_0_3_f = o295966_2_clamp_false;
vec4 o295992_0_3_rgba = o295992_fct((uv), vec2(p_o295992_center_x, p_o295992_center_y)+vec2(0.5), _seed_variation_);
vec4 o295965_3_b = vec4(vec3(o295967_0_5_f), 1.0);
vec4 o295965_3_l;
float o295965_3_a;

o295965_3_l = vec4(vec3(o295966_0_3_f), 1.0);
o295965_3_a = p_o295965_amount1*1.0;
o295965_3_b = vec4(blend_normal((uv), o295965_3_l.rgb, o295965_3_b.rgb, o295965_3_a*o295965_3_l.a), min(1.0, o295965_3_b.a+o295965_3_a*o295965_3_l.a));

o295965_3_l = o295992_0_3_rgba;
o295965_3_a = p_o295965_amount2*1.0;
o295965_3_b = vec4(blend_additive((uv), o295965_3_l.rgb, o295965_3_b.rgb, o295965_3_a*o295965_3_l.a), min(1.0, o295965_3_b.a+o295965_3_a*o295965_3_l.a));

vec4 o295965_0_5_rgba = o295965_3_b;
vec4 o295968_0_3_rgba = o295968_gradient_gradient_fct((dot((o295965_0_5_rgba).rgb, vec3(1.0))/3.0));
float o295984_0_4_f = shape_circle((uv), p_o295984_sides, p_o295984_radius*1.0, p_o295984_edge*1.0);
float o295985_2_clamp_false = smoothstep(0.0, 1.0, o295984_0_4_f);
float o295985_2_clamp_true = clamp(o295985_2_clamp_false, 0.0, 1.0);
float o295985_0_3_f = o295985_2_clamp_false;
vec4 o295982_3_b = o295968_0_3_rgba;
vec4 o295982_3_l;
float o295982_3_a;

o295982_3_l = o295943_1_7_rgba;
o295982_3_a = p_o295982_amount1*1.0;
o295982_3_b = vec4(blend_multiply((uv), o295982_3_l.rgb, o295982_3_b.rgb, o295982_3_a*o295982_3_l.a), min(1.0, o295982_3_b.a+o295982_3_a*o295982_3_l.a));

o295982_3_l = vec4(vec3(o295985_0_3_f), 1.0);
o295982_3_a = p_o295982_amount2*1.0;
o295982_3_b = vec4(blend_multiply((uv), o295982_3_l.rgb, o295982_3_b.rgb, o295982_3_a*o295982_3_l.a), min(1.0, o295982_3_b.a+o295982_3_a*o295982_3_l.a));

vec4 o295982_0_5_rgba = o295982_3_b;
vec4 o295986_3_b = o295982_0_5_rgba;
vec4 o295986_3_l;
float o295986_3_a;

o295986_3_l = o295982_0_5_rgba;
o295986_3_a = p_o295986_amount1*1.0;
o295986_3_b = vec4(blend_additive((uv), o295986_3_l.rgb, o295986_3_b.rgb, o295986_3_a*o295986_3_l.a), min(1.0, o295986_3_b.a+o295986_3_a*o295986_3_l.a));

vec4 o295986_0_5_rgba = o295986_3_b;
vec3 o295988_3_clamp_false = pow(((o295986_0_5_rgba).rgb),vec3(p_o295988_d_in2_x, p_o295988_d_in2_y, p_o295988_d_in2_z));
vec3 o295988_3_clamp_true = clamp(o295988_3_clamp_false, vec3(0.0), vec3(1.0));
vec3 o295988_0_5_rgb = o295988_3_clamp_false;
vec3 o295983_0_3_rgb = aces_tonemap(o295988_0_5_rgb);
float o295989_1_3_f = vec4(o295983_0_3_rgb, 1.0).g;
float o295989_2_4_f = vec4(o295983_0_3_rgb, 1.0).b;
vec4 o295990_0_1_rgba = vec4((dot((o295991_0_1_rgba).rgb, vec3(1.0))/3.0), o295989_1_3_f, o295989_2_4_f, 1.0);
float o296001_0_1_f = shape_polygon((uv), p_o296001_sides, p_o296001_radius*1.0, p_o296001_edge*1.0);
vec4 o296000_0_b = o295990_0_1_rgba;
vec4 o296000_0_l;
float o296000_0_a;

o296000_0_l = vec4(vec3(o296001_0_1_f), 1.0);
o296000_0_a = p_o296000_amount1*1.0;
o296000_0_b = vec4(blend_multiply((uv), o296000_0_l.rgb, o296000_0_b.rgb, o296000_0_a*o296000_0_l.a), min(1.0, o296000_0_b.a+o296000_0_a*o296000_0_l.a));

vec4 o296000_0_2_rgba = o296000_0_b;

	vec4 color_tex = o296000_0_2_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}




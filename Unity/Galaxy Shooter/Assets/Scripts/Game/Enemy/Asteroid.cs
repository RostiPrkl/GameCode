using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : MonoBehaviour
{
    private Player _player;
    private PowerUpSpawnManager _powerUp;
    private CircleCollider2D _cc;
    private SpriteRenderer _sr;
    private Coroutine _fadeOutCoroutine;

    [SerializeField] private float _moveSpeed = 6.0f;
    [SerializeField] private float _rotationSpeed = 50;
    [SerializeField] private float _minYPosition = -10.2f;
    
    [SerializeField] private GameObject _expolsionPrefab;


    void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        if (_player == null)
            Debug.Log("PLAYER NULL");

        _powerUp = GameObject.Find("PowerUpSpawnManager").GetComponent<PowerUpSpawnManager>();
        if (_powerUp == null)
            Debug.Log("PWUP SPAWNMANAGER NULL");

        _sr = GetComponent<SpriteRenderer>();
        if (_sr == null)
            Debug.Log("SPRITERENDERER NULL");

        _cc = GetComponent<CircleCollider2D>();
        if (_cc == null)
            Debug.Log("BOXCOLLIDER NULL");
    }


    void Update()
    {
        transform.Rotate(Vector3.forward * _rotationSpeed * Time.deltaTime);
        transform.Translate(Vector3.down * _moveSpeed * Time.deltaTime, Space.World);
        
        if (transform.position.y <= _minYPosition)
            Destroy(this.gameObject);
    }


    private void OnTriggerEnter2D(Collider2D other) 
    {
        if (other.CompareTag("Player"))
        {
            Player player = other.transform.GetComponent<Player>();
            if (player != null)
            {
                Instantiate(_expolsionPrefab, transform.position, Quaternion.identity);
                _moveSpeed = 0.2f;
                _cc.enabled = false;
                player.Damage();
            }
        }

        if (other.CompareTag("Laser"))
        {
            Destroy(other.gameObject);
            if (_player != null)
            {
                Instantiate(_expolsionPrefab, transform.position, Quaternion.identity);
                _moveSpeed = 0.5f;
                _cc.enabled = false;
                _powerUp.StartSpawn(transform.position);
            }
        
        }

        if (other.CompareTag("Enemy"))
            {
                Destroy(other.gameObject);
                Instantiate(_expolsionPrefab, transform.position, Quaternion.identity);
                _moveSpeed = 0.5f;
                _cc.enabled = false;
            }

         if (_fadeOutCoroutine == null)
        {
            _fadeOutCoroutine = StartCoroutine(FadeOutAndDestroy(1.0f));
        }
    }


    private IEnumerator FadeOutAndDestroy(float duration)
    {
        float elapsedTime = 0.0f;
        Color initialColor = _sr.color;

        while (elapsedTime < duration)
        {
            float alpha = Mathf.Lerp(initialColor.a, 0.0f, elapsedTime / duration);
            _sr.color = new Color(initialColor.r, initialColor.g, initialColor.b, alpha);

            elapsedTime += Time.deltaTime;
            yield return null;
        }

        Destroy(this.gameObject);
        _fadeOutCoroutine = null;
    }
}

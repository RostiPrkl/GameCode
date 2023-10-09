using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    private Player _player;
    private Animator _anim;
    private BoxCollider2D _bc;

    private AudioSource _audioSource;

    [SerializeField] private float _moveSpeed = 4.0f;
    [SerializeField] private float _increaseSpeedAmount = 0.1f; 
    [SerializeField] private float _increaseInterval = 10.0f;
    [SerializeField] private float _maxYPosition = 7.6f;
    [SerializeField] private float _minYPosition = -5.2f;

    [SerializeField] private GameObject _laserPrefab;

    [SerializeField] private AudioClip _explosion;



    private void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        if (_player == null)
            Debug.Log("PLAYER NULL");
        _anim = GetComponent<Animator>();
        if (_anim == null)
            Debug.Log("ANIMATOR NULL");
        _bc = GetComponent<BoxCollider2D>();
        if (_bc == null)
            Debug.Log("BOXCOLLIDER NULL");
        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
            Debug.Log("ENEMYAUDIO NULL");

        StartCoroutine(IncreaseSpeedRoutine());
    }


    private void Update()
    {
        Movement();
    }


    private void Movement()
    {
        transform.Translate(Vector3.down * _moveSpeed * Time.deltaTime);

        if (transform.position.y <= _minYPosition)
            transform.position = new Vector3(Random.Range(-10.0f, 10.0f), _maxYPosition, 0.0f);
    }


    private void OnTriggerEnter2D(Collider2D other) 
    {
        if (other.CompareTag("Player"))
        {
            Player player = other.transform.GetComponent<Player>();
            if (player != null)
            {
                _anim.SetTrigger("OnEnemyDeath");
                _bc.enabled = false;
                _moveSpeed = 0.2f;
                player.Damage();
            }
            Destroy(this.gameObject, 2.5f);
            _audioSource.clip = _explosion;
            _audioSource.Play();
        }

        if (other.CompareTag("Laser"))
        {
            Destroy(other.gameObject);
            if (_player != null)
            {
                _anim.SetTrigger("OnEnemyDeath");
                _bc.enabled = false;
                _moveSpeed = 0.9f;
                _player.AddScore(1);
            }
            
            Destroy(this.gameObject, 2.5f);
            _audioSource.clip = _explosion;
            _audioSource.Play();
        }

        if (other.CompareTag("Asteroid"))
        {
            _anim.SetTrigger("OnEnemyDeath");
            _bc.enabled = false;
            _moveSpeed = 0.2f;
            Destroy(this.gameObject, 2.5f);
            _audioSource.clip = _explosion;
            _audioSource.Play();
        }
    }


    private IEnumerator IncreaseSpeedRoutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(_increaseInterval);
            IncreaseSpeed();
        }
    }


    private void IncreaseSpeed()
    {
        _moveSpeed += _increaseSpeedAmount;
        if (_moveSpeed > 25f)
            _moveSpeed = 25f;
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    private float _canFire = -1f;
    private SpawnManager _spawnManager;
    private UIManager _uiManager;

    private bool _tripleShotActive = false;
    private bool _speedActive = false;
    private bool _shieldActive = false;
    
    private AudioSource _audioSource;

    [SerializeField] private float _horizontalSpeed = 1f;
    [SerializeField] private float _verticalSpeed = 1f;

    [SerializeField] private  GameObject _laserPrefab;
    [SerializeField] private  GameObject _tripleShotPrefab;
    [SerializeField] private GameObject _ShieldAnimation;
    [SerializeField] private GameObject _expolsionPrefab;

    [SerializeField] private GameObject _damage01;
    [SerializeField] private GameObject _damage02;

    [SerializeField] private float _fireRate = 0.6f;
    [SerializeField] private int _lives = 3;
    [SerializeField] private int _score = 0;

    [SerializeField] private AudioClip _laserAudioClip;
    [SerializeField] private AudioClip _shielDownAudio;
    


    void Start()
    {
        transform.position = new Vector3(0,-2,0);

        _spawnManager = GameObject.Find("SpawnManager").GetComponent<SpawnManager>();
        if (_spawnManager == null)
            Debug.Log("SPWANMANAGER NULL");
        _uiManager = GameObject.Find("Canvas").GetComponent<UIManager>();
        if (_uiManager == null)
            Debug.Log("UIMANAGER NULL");
        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
            Debug.Log("PLAYERAUDIO NULL");
    }


    void Update()
    {
        Movement();
        Laser();
    }


    private void Movement()
    {
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");

        if (_speedActive == true)
        {
            transform.Translate((Vector3.right * horizontalInput * (_horizontalSpeed * 2)) * Time.deltaTime);
            transform.Translate((Vector3.up * verticalInput * (_verticalSpeed * 2)) * Time.deltaTime);
            _fireRate =  0.08f;
        }
        else
        {
            transform.Translate((Vector3.right * horizontalInput * _horizontalSpeed) * Time.deltaTime);
            transform.Translate((Vector3.up * verticalInput * _verticalSpeed) * Time.deltaTime);
            _fireRate =  0.25f;
        }
        
        transform.position = new Vector3(transform.position.x, Mathf.Clamp(transform.position.y, -4f, 0f), 0);

        if (transform.position.x >= 11.3f)
            transform.position = new Vector3(-11.3f, transform.position.y, 0);
        else if (transform.position.x <= -11.3f)
            transform.position = new Vector3(11.3f, transform.position.y, 0);
    }


    private void Laser()
    {
        Vector3 offset = transform.position;

        if (Input.GetKeyDown(KeyCode.Space) && Time.time > _canFire)
        {
            _canFire = Time.time + _fireRate;
            if (_tripleShotActive == true)
                Instantiate(_tripleShotPrefab, offset, Quaternion.identity);
            else
            {
                offset.y += 0.75f;
                Instantiate(_laserPrefab, offset, Quaternion.identity);
            }

            _audioSource.clip = _laserAudioClip;
            _audioSource.Play();
        }
    }


    public void Damage()
    {
        if (_shieldActive == true)
        {
            float originalVolume = _audioSource.volume;
            _audioSource.volume = 5.0f;
            _audioSource.clip = _shielDownAudio;
            _audioSource.Play();
            _audioSource.volume = originalVolume;
            _shieldActive = false;
            _ShieldAnimation.SetActive(false);
        }
        else
        {
            _lives--;
            _uiManager.UpdateLives(_lives);
        }

        if (_lives < 3)
            _damage01.SetActive(true);
        if (_lives < 2)
            _damage02.SetActive(true);
        if (_lives < 1)
        {
            GameOver();
        }
    }


    private Coroutine _tripleShotCoroutine;

    public void TripleShotActive()
    {
        _tripleShotActive = true;

         if (_tripleShotCoroutine != null)
            StopCoroutine(_tripleShotCoroutine);

    _tripleShotCoroutine = StartCoroutine(TripleShotPowerDownRoutine());

    }


    IEnumerator TripleShotPowerDownRoutine()
    {
        yield return new WaitForSeconds(10.0f);
        _tripleShotActive = false;
    }


    private Coroutine _speedCoroutine;

    public void SpeedActive()
    {
        _speedActive = true;
        
        if (_speedCoroutine != null)
            StopCoroutine(_speedCoroutine);

    _speedCoroutine = StartCoroutine(SpeedPowerDownRoutine());
    }


    IEnumerator SpeedPowerDownRoutine()
    {
        yield return new WaitForSeconds(15.0f);
        _speedActive = false;
    }


    public void ShieldActive()
    {
        _shieldActive = true;
        _ShieldAnimation.SetActive(true);
    }


    public void AddScore(int points)
    {
        _score += points;
        _uiManager.UpdateScore(_score);
    }

    public void GameOver()
    {
        Destroy(this.gameObject);
        _damage01.SetActive(false);
        _damage02.SetActive(false);
        Instantiate(_expolsionPrefab, transform.position, Quaternion.identity);
        _spawnManager.StopSpawning();
    }

}

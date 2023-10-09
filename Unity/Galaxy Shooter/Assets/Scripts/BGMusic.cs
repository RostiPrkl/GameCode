using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BGMusic : MonoBehaviour
{
    
    private Player _player;
    private AudioSource _audioSource;
    private bool alreadyPlayed;

    [SerializeField] private AudioClip _gameOver;
    [SerializeField] private AudioClip _gameStart;
    [SerializeField] private AudioClip _gameBG;


      void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        if (_player == null)
            Debug.Log("PLAYER NULL");

        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
            Debug.Log("BGAUDIO NULL");

        StartCoroutine(StartGame());
    }


    void Update()
    {
        if(alreadyPlayed) return;
        GameOver();
    }

    void GameOver()
    {
        if (_player == null)
        {
            alreadyPlayed = true;
            _audioSource.clip = _gameOver;
            _audioSource.Play();
        }
    }

    private IEnumerator StartGame()
    {
        float originalVolume = _audioSource.volume;
        _audioSource.volume = 1.0f;
        _audioSource.PlayOneShot(_gameStart);
        yield return new WaitForSeconds(_gameStart.length);
        _audioSource.volume = originalVolume;
        _audioSource.clip = _gameBG;
        _audioSource.Play();
    }
    
}

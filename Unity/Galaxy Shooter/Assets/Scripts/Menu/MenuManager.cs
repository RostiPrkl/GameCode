using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuManager : MonoBehaviour
{
    private AudioSource _audioSource;

    [SerializeField] private float _fadeDuration = 0.4f;

    private bool _isFadingOut = false;

    private void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
        {
            Debug.Log("AudioSource component not found.");
        }
    }

    public void StartGame()
    {
        if (!_isFadingOut)
        {
            StartCoroutine(FadeOutVolumePlayStartGame());
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }

    private IEnumerator FadeOutVolumePlayStartGame()
    {
        _isFadingOut = true;

        float startVolume = _audioSource.volume;
        float startTime = Time.time;

        while (Time.time - startTime < _fadeDuration)
        {
            float t = (Time.time - startTime) / _fadeDuration;
            _audioSource.volume = Mathf.Lerp(startVolume, 0.0f, t);
            yield return null;
        }

        _audioSource.volume = 0.0f;
        _audioSource.Stop();
        SceneManager.LoadScene(1);
    }


    public void QuitGame()
    {
        Application.Quit();
    }
}

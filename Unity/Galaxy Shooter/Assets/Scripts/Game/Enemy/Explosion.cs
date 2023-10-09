using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosion : MonoBehaviour
{
    private AudioSource _audioSource;


    void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
            Debug.Log("EXPLOSIONAUDIO NULL");
        _audioSource.Play();

        Destroy(this.gameObject, 3f);
    }
}

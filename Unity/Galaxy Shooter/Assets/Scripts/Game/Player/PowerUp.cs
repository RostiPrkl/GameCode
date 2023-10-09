using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerUp : MonoBehaviour
{
    [SerializeField] private float _moveSpeed = 4.0f;
    [SerializeField] private float _minYPosition = -5.50f;
    [SerializeField] private int _powerUpID;

    [SerializeField] private AudioClip _shieldUpAudio;
    [SerializeField] private AudioClip _speedAudio;
    [SerializeField] private AudioClip _tripleShotAudio;


    void Update()
    {
        transform.Translate(Vector3.down * _moveSpeed * Time.deltaTime);
        if (transform.position.y < _minYPosition)
            Destroy(this.gameObject);

    }


    private void OnTriggerEnter2D(Collider2D other) 
    {
        if (other.CompareTag("Player"))
        {
            Player player = other.transform.GetComponent<Player>();
            switch (_powerUpID)
            {
                case 0:
                    player.TripleShotActive();
                    AudioSource.PlayClipAtPoint(_tripleShotAudio, Camera.main.transform.position);
                    break;
                case 1:
                    player.SpeedActive();
                    AudioSource.PlayClipAtPoint(_speedAudio, Camera.main.transform.position);
                    break;
                case 2:
                    player.ShieldActive();
                    AudioSource.PlayClipAtPoint(_shieldUpAudio, Camera.main.transform.position);
                    break;
            }
            Destroy(this.gameObject);
        }
    }

}

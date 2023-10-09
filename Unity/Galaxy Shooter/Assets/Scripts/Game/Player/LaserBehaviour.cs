using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBehaviour : MonoBehaviour
{
    [SerializeField] private float _speed = 4.5f;


    void Update()
    {
        PlayerLaser();
    }


    void PlayerLaser()
    {
        transform.Translate((Vector3.up * _speed) * Time.deltaTime);

        if (transform.position.y > 8f)
        {
            if (transform.parent != null)
                Destroy(transform.parent.gameObject);
            Destroy(gameObject);
        }
    }
}

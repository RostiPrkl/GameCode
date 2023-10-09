using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyOverTime : MonoBehaviour
{
    [SerializeField] float lifetime = 1f;


    void Update()
    {
        Destroy(gameObject, lifetime);        
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BillBoard : MonoBehaviour
{
    private SpriteRenderer sr;


    void Start()
    {
        sr = GetComponent<SpriteRenderer>();
        sr.flipX = true;
    }


    void Update()
    {
        transform.LookAt(PlayerController.instance.transform.position, -Vector3.forward); 
    }
}

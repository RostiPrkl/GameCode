using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Block : MonoBehaviour
{
    private GameObject player;

    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
    }


    void Update()
    {
        if (transform.position.y < player.transform.position.y)
        {
            gameObject.layer = LayerMask.NameToLayer("Cube_Active");
            gameObject.GetComponent<Renderer>().material.color = Color.red;
        }
    }
}

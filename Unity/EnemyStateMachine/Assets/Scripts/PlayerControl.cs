using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerControl : MonoBehaviour
{
    float moveSpeed = 5;
    float rotateSpeed = 200;


    void Start()
    {
        
    }

    
    void Update()
    {
        float xInput = Input.GetAxis("Horizontal") * moveSpeed * Time.deltaTime;
        float zInput = Input.GetAxis("Vertical") * moveSpeed * Time.deltaTime;
        transform.Translate(xInput, 0, zInput);

        float mouseInput = Input.GetAxis("Mouse X") * rotateSpeed * Time.deltaTime;
        Vector3 lookHere = new Vector3(0, mouseInput, 0);
        transform.Rotate(lookHere);
    }
}

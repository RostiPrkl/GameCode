using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthCube : MonoBehaviour
{
    [SerializeField] private float speed;
    [SerializeField] private float rotationspeed;
    [SerializeField] private Transform[] movePoint;
    [SerializeField] private float healAmount = 15;

    private int i;

    void Start()
    {
        transform.position = movePoint[0].position;
    }


    void Update()
    {
        transform.position = Vector3.MoveTowards(transform.position, movePoint[i].position, speed * Time.deltaTime);

        if(Vector2.Distance(transform.position, movePoint[i].position) < .25f)
        {
            i++;

            if(i >= movePoint.Length)
            i = 0;
        }

        if(transform.position.x > movePoint[i].position.x)
            transform.Rotate(new Vector3(0, 0, rotationspeed * Time.deltaTime));
        else
            transform.Rotate(new Vector3(0, 0, -rotationspeed * Time.deltaTime));
            
    }

    private void OnTriggerEnter (Collider collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            player player = collision.gameObject.GetComponent<player>();

            player.health += healAmount;
            
            if (player.health >= 100)
                player.health = 100;
                
            Destroy(transform.root.gameObject);
        }
    }

}

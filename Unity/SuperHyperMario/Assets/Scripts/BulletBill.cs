using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletBill : MonoBehaviour
{
    public GameObject player;


    [Header("Bullet Info")]
    public GameObject bullet;
    public float bulletSpeed = 5;
    [SerializeField] float bulletCounter;
    [SerializeField] float bulletMaxCounter;

    void Start()
    {

    }


    void Update()
    {
        if (player != null)
        {
            if (bulletCounter > bulletMaxCounter)
            {
                bulletCounter = 0;
                bulletMaxCounter = Random.Range(0.5f, 3);

                Vector3 cannonToPlayer = player.transform.position - transform.position;
                Vector3 shootingDirection = new Vector3(Mathf.Sign(cannonToPlayer.x), 0, 0);

                GameObject bulletInstance = Instantiate(bullet, transform.position, Quaternion.identity);
                bulletInstance.transform.localScale = new Vector3(-shootingDirection.x, 1, 1);
                bulletInstance.GetComponent<Rigidbody2D>().velocity = shootingDirection * bulletSpeed;
            }
            else
            {
                bulletCounter += Time.deltaTime;
            }

            
        }
    }
}

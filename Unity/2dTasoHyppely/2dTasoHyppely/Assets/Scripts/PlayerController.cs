using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [SerializeField] float jumpForce;
    [SerializeField] float moveSpeed;

    Animator animator;
    Rigidbody2D rb;


    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }


    void Update()
    {
       transform.Translate(Input.GetAxis("Horizontal") * moveSpeed * Time.deltaTime, 0, 0);

        if (Input.GetAxisRaw("Horizontal") != 0)
        {
            transform.localScale = new Vector3(Input.GetAxisRaw("Horizontal"), 1, 1);
            animator.SetBool("Walk", true);
        }
        else
            animator.SetBool("Walk", false);

        if (Input.GetButtonDown("Jump") && rb.velocity.y == 0)
        {
            rb.velocity = new Vector2(0, jumpForce);
            animator.SetTrigger("Jump");
        }
    }
}

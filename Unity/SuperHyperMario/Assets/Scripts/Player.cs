using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [Header("Move Info")]
    [SerializeField] float moveSpeed;
    [SerializeField] float jumpForce;

    [SerializeField] float fallMultiplier = 0.5f;
    [SerializeField] float lowJumpMultiplier = 2;

    [SerializeField] bool grounded;

    Animator animator;
    Rigidbody2D rb;
    Component groundCheck;




    void Start()
    {
        animator = GetComponent<Animator>();   
        rb = GetComponent<Rigidbody2D>();
        groundCheck = GetComponent<Component>();

    }


    void Update()
    {
        GroundDetect();

        transform.Translate(Input.GetAxis("Horizontal") * moveSpeed * Time.deltaTime, 0, 0);
        if (Input.GetAxisRaw("Horizontal") != 0)
        {
            transform.localScale = new Vector3(Input.GetAxisRaw("Horizontal"), 1, 1);
            animator.SetBool("Walk", true);
        }
        else
        {
            animator.SetBool("Walk", false);
        }


        if (Input.GetButtonDown("Jump"))
        {
            rb.velocity = new Vector2(rb.velocity.x, jumpForce);
            animator.SetBool("Jump", true);
        }

        if (rb.velocity.y < 0)
            rb.velocity += Vector2.up * Physics.gravity.y * (fallMultiplier - 1) * Time.deltaTime;
        else if (rb.velocity.y > 0 && !Input.GetButton("Jump"))
            rb.velocity += Vector2.up * Physics2D.gravity.y * (lowJumpMultiplier - 1) * Time.deltaTime;
    }

    void GroundDetect()
    {
        Vector3 checkPosition = groundCheck.transform.position;
        RaycastHit2D casthit = Physics2D.BoxCast(checkPosition, new Vector2(1.3f, 0.2f), 0, Vector2.zero, LayerMask.GetMask("Ground"));

        if (casthit == true && rb.velocity.y <= 0)
        {
            grounded = true;
            animator.SetBool("Jump", false);
        }
        else
            grounded = false;
    }
}

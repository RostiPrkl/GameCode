using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class PlayerController : MonoBehaviour
{
    [Header("Move Info")]
    [SerializeField] float jumpForce;
    [SerializeField] float moveSpeed;

    [Header("Health Info")]
    public float health;
    [SerializeField] float previousHealth;
    public float maxHealth;
    [SerializeField] float counter;
    [SerializeField] float maxCounter;
    [SerializeField] Image filler;

    [Header("GroundCheck")]
    [SerializeField] Transform groundCheckPosition;
    [SerializeField] LayerMask groundCheckLayer;
    [SerializeField] float groundCheckRadius;
    bool isGrounded;

    Animator animator;
    Rigidbody2D rb;


    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }


    void Update()
    {
        Movement();
        HealtBar();
    }

    private void HealtBar()
    {
        if (counter > maxCounter)
        {
            previousHealth = health;
            counter = 0;
        }
        else
            counter += Time.deltaTime;

        filler.fillAmount = Mathf.Lerp(previousHealth / maxHealth, health / maxHealth, counter / maxCounter);
    }

    private void Movement()
    {
        if (Physics2D.OverlapCircle(groundCheckPosition.position, groundCheckRadius, groundCheckLayer))
            isGrounded = true;
        else
            isGrounded = false;

        transform.Translate(Input.GetAxis("Horizontal") * moveSpeed * Time.deltaTime, 0, 0);

        if (Input.GetAxisRaw("Horizontal") != 0)
        {
            transform.localScale = new Vector3(Input.GetAxisRaw("Horizontal"), 1, 1);
            animator.SetBool("Walk", true);
        }
        else
            animator.SetBool("Walk", false);

        if (Input.GetButtonDown("Jump") && isGrounded == true)
        {
            rb.velocity = new Vector2(0, jumpForce);
            animator.SetTrigger("Jump");
        }
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Trap"))
        {
            Debug.Log("HIT");
            TakeDamage(30);
        }


        if (collision.gameObject.CompareTag("FallCheck"))
        {
            SceneManager.LoadScene("Map");
        }
    }

    void TakeDamage(float _dmg)
    {
        previousHealth = filler.fillAmount * maxHealth;
        counter = 0;
        health -= _dmg;
    }
}

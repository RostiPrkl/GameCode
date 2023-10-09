using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public static PlayerController instance;

    public Rigidbody2D rb;
    [SerializeField] float moveSpeed = 5;
    private Vector2 moveInput;
    private Vector2 mouseInput;
    [SerializeField] float mouseSensitivity = 1f;
    [SerializeField] Camera viewCam;
    [SerializeField] GameObject bullet; 
    [SerializeField] public int currentAmmo;
    [SerializeField] Animator gunAnim;

    [SerializeField] int currentHealth;
    [SerializeField] int maxHealth = 150;
    [SerializeField] GameObject deathScreen;
    private bool hasDied = false;



    void Awake()
    {
        instance = this;
    }

    
    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        currentHealth = 100;
    }

    
    void Update()
    {
        if(!hasDied)
        {
            Movement();
            Shoot();
        }
    }


    void Movement()
    {
        moveInput = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        Vector3 movementHor = transform.up * -moveInput.x;
        Vector3 movementVert = transform.right * moveInput.y;
        rb.velocity = (movementHor + movementVert) * moveSpeed;
        
        // Calculate the absolute value of the input to determine animation intensity
        float inputMagnitude = Mathf.Abs(moveInput.x) + Mathf.Abs(moveInput.y);

        // Set the "Walk" parameter in the Animator based on input intensity
        gunAnim.SetFloat("Walk", inputMagnitude);

        //mouse movement
        mouseInput = new Vector2(Input.GetAxisRaw("Mouse X"), Input.GetAxisRaw("Mouse Y")) * mouseSensitivity;
        transform.rotation = Quaternion.Euler(transform.rotation.eulerAngles.x, transform.rotation.eulerAngles.y, transform.rotation.eulerAngles.z - mouseInput.x);
        viewCam.transform.localRotation = Quaternion.Euler(viewCam.transform.localRotation.eulerAngles + new Vector3(0f, mouseInput.y, 0f));  
    }


    void Shoot()
    {
        //shooting mech
        if(Input.GetMouseButtonDown(0) && currentAmmo == 0)
            Debug.Log("out of ammo!");
        else if(Input.GetMouseButtonDown(0) && currentAmmo > 0)  
            StartCoroutine(ShootWithDelay(0.2f));
    }


    IEnumerator ShootWithDelay(float delay)
    {
        gunAnim.SetTrigger("Shoot");
        yield return new WaitForSeconds(delay); // Wait for the specified delay
        currentAmmo--;
        Ray ray = viewCam.ViewportPointToRay(new Vector3(.5f, .5f, 0f));
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            Instantiate(bullet, hit.point, transform.rotation);
            if (hit.transform.tag == "Enemy")
                hit.transform.parent.GetComponent<EnemyController>().TakeDamage();
        }
    }


    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        if(currentHealth <= 0)
        {
            deathScreen.SetActive(true);
            hasDied = true;
        }
    }


    public void AddHealth(int healAmount)
    {
        currentHealth += healAmount;
        if(currentHealth > maxHealth)
        {
            currentHealth = maxHealth;
        }
    }
}

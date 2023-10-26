using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

//pari lisäkenttää <-- tehdään kun ehditään
//ui-elementtejä (forcemittari, healthbar) <--tehdään kun ehditään
//obstacleen scripti jolla obs voi pyöriä <-- done
//kun painetaan esc, peli sukeutuu <-- done
//health pack <-- done
//partikkeliefektejä!! <-- done
//maxforce <-- done

public class player : MonoBehaviour
{
    [SerializeField] float forceMultiplier = 50f;
    [SerializeField] public float health = 100f;
    [SerializeField] float highPoint;

    private float force = 0f;
    private float maxForce = 40f;
    private float damage;
    
    private bool goingDown = false;
    private bool hasDamaged = false;
    private bool debugScreen = false;

    Rigidbody rb;
    public GUIStyle myStyle;


    void Start()
    {
        rb = GetComponent<Rigidbody>();
        myStyle.fontSize = 24;
        myStyle.normal.textColor = Color.white;
    }

    
    void Update()
    {

        if (Input.GetKey(KeyCode.Mouse0) && rb.velocity.y == 0)
        {
            force += forceMultiplier * Time.deltaTime;
            if (force >= maxForce)
                force = maxForce;
        }

        if (Input.GetMouseButtonUp(0))
            Launch();

        if (Input.GetKeyDown(KeyCode.BackQuote))
            debugScreen = !debugScreen;

        if (rb.velocity.y < 0 && goingDown == false)
        {
            goingDown = true;
            GetComponent<Renderer>().material.color = Color.yellow;
            highPoint = transform.position.y;
        }
    }


    void Launch()
    {
        GetComponent<Renderer>().material.color = Color.blue;
        Vector3 mousePosition = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        Vector3 launchDirection = (mousePosition - transform.position).normalized;
        rb.AddForce(launchDirection * force, ForceMode.Impulse);

        force = 0;
        goingDown = false;
        hasDamaged = false;
    }


    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block") && !hasDamaged)
        {
            if (goingDown == true)
            {
                damage = Mathf.Sqrt(2f * Mathf.Abs(Physics.gravity.y) * Mathf.Abs(highPoint - transform.position.y));
                Damage(damage);

                hasDamaged = true;
            }
        }

        if (collision.gameObject.CompareTag("obstacle"))
            Damage(20);

        if (collision.gameObject.CompareTag("LevelEnd"))
            SceneManager.LoadScene(collision.gameObject.GetComponent<LevelEnd>().Level);

    }


    void Damage(float _damageTaken)
    {
        health -= _damageTaken;
        if (health <= 0f)
            gameOver();
    }


    private void OnGUI()
    {
        if(debugScreen)
        {
            GUI.Label(new Rect(10, 10, 200, 50), "force " + force, myStyle);
            GUI.Label(new Rect(10, 30, 200, 50), "health " + health, myStyle);
            GUI.Label(new Rect(10, 50, 200, 50), "Damage " + damage, myStyle);
            GUI.Label(new Rect(10, 70, 200, 50), "Has Damaged " + hasDamaged, myStyle);
            GUI.Label(new Rect(10, 90, 200, 50), "High Point " + highPoint, myStyle);
            GUI.Label(new Rect(10, 110, 200, 50), "Going Down " + goingDown, myStyle);
        }
    }


    void gameOver() => SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
}

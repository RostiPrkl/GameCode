using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorOpen : MonoBehaviour
{
    [SerializeField] GameObject door;
    [SerializeField] AudioSource doorAudio;

    private bool isInRange = false;


    private void Update()
    {
        if (isInRange && Input.GetKeyDown(KeyCode.E))
        {
            door.GetComponent<Animator>().Play("Door_open");
            doorAudio.Play();
            StartCoroutine(DoorCloseDelay());
        }
    }
    

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
            isInRange = true;

        if (other.CompareTag("Enemy"))
        {
            door.GetComponent<Animator>().Play("Door_open");
            doorAudio.Play();
            StartCoroutine(DoorCloseDelay());
        }
    }


    private IEnumerator DoorCloseDelay()
    {
        yield return new WaitForSeconds(2.5f);
        door.GetComponent<Animator>().Play("Door_close");
        doorAudio.Play();
    }


    void OnTriggerExit(Collider other)
    {
        isInRange = false;
    }
}

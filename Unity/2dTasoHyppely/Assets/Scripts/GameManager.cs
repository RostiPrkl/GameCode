using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager manager;


    private void Awake()
    {
        if (manager == null)
        {
            DontDestroyOnLoad(gameObject);
            manager = this;
        }

        else
        {
            Destroy(gameObject);
        }
    }


    void Start()
    {
        
    }


    void Update()
    {
        
    }
}

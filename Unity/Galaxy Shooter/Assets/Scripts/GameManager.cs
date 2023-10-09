using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    private bool _isGameOver = false;
    private bool _isGamePaused = false;

    [SerializeField] private GameObject pauseMenu;


    private void Start() 
    {
        Cursor.visible = false;    
    }


    private void Update() 
    {
        if (Input.GetKeyDown(KeyCode.R) && _isGameOver == true)
            SceneManager.LoadScene(1);    
        if (Input.GetKeyDown(KeyCode.Q) && _isGameOver == true)
            Application.Quit();    
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            TogglePause();
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            }
    }


    public void GameOver()
    {
        _isGameOver = true;
    }

    void TogglePause()
    {
        _isGamePaused = !_isGamePaused;

        if (_isGamePaused)
        {
            Time.timeScale = 0;
            Cursor.visible = true;
            pauseMenu.SetActive(true);
            AudioListener.pause = true;
        }
        else
        {
            ResumeGame();
        }
    }


     public void ResumeGame()
    {
        Time.timeScale = 1;
        Cursor.visible = false;
        pauseMenu.SetActive(false);
        AudioListener.pause = false;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }
}

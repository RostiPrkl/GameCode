using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    private GameManager _gameManager;
    
    [SerializeField] private TMPro.TextMeshProUGUI _scoreText;
    [SerializeField] private TMPro.TextMeshProUGUI _gameOverText;
    [SerializeField] private TMPro.TextMeshProUGUI _infoText;
    [SerializeField] private  Sprite[] _liveSprites;
    [SerializeField] private Image _livesImg;

    
    void Start()
    {
        _gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
        if (_gameManager == null)
            Debug.Log("GAMEMANAGER NULL");

        _gameOverText.gameObject.SetActive(false);
        _scoreText.text = "Score " + 0;

        
    }


    public void UpdateScore(int playerScore)
    {
        _scoreText.text = "Score " + playerScore.ToString();
    }


    public void UpdateLives(int currentLives)
    {
        _livesImg.sprite = _liveSprites[currentLives];

        if (currentLives == 0)
            {
                GameOverToggles();
            }
    }


    private void GameOverToggles()
    {
        StartCoroutine(ToggleGameOverText());
        StartCoroutine(ToggleInfoText());
        _gameManager.GameOver();
    }


    IEnumerator ToggleGameOverText()
    {
        while (true)
        {
            _gameOverText.gameObject.SetActive(true);
            yield return new WaitForSeconds(0.6f);
            _gameOverText.gameObject.SetActive(false);
            yield return new WaitForSeconds(0.6f);
        }
    }


    IEnumerator ToggleInfoText()
    {
        while (true)
        {
            _infoText.gameObject.SetActive(true);
            yield return new WaitForSeconds(0.6f);
            _infoText.gameObject.SetActive(false);
            yield return new WaitForSeconds(0.6f);
        }
    }

    public void ResumePlay()
    {
        _gameManager.ResumeGame();
    }

    public void QuitGame()
    {
        Application.Quit();
    }


}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinGenerator : MonoBehaviour
{
    [Header("Coin Amount Range")]
    [SerializeField] private int minCoins;
    [SerializeField] private int maxCoins;
    private int coinAmount;

    [Header("Coin Script")]
    [SerializeField] private GameObject coinPrefab;
    [SerializeField] private SpriteRenderer[] coinImg;

    void Start()
    {
        for(int i = 0; i < coinImg.Length; i++)
            coinImg[i].sprite = null;

        coinAmount = Random.Range(minCoins, maxCoins);
        int additionalOffset = coinAmount / 2;

        for (int i = 0; i < coinAmount; i ++)
        {
            Vector3 offset = new Vector2(i - additionalOffset, 0);
            Instantiate(coinPrefab, transform.position + offset, Quaternion.identity, transform);
        }
    }
}

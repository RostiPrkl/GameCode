using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerUpSpawnManager : MonoBehaviour
{
    private bool _stopSpawnPowerUp = false;

    [SerializeField] private GameObject[] _powerUpPrefabs;


    public void StartSpawn(Vector3 spawnPosition)
    {
        SpawnPowerUp(spawnPosition);
    }


    private void SpawnPowerUp(Vector3 spawnPosition)
    {      
        if (!_stopSpawnPowerUp)
        {
            int randomIndex = Random.Range(0, _powerUpPrefabs.Length);
            GameObject selectedPowerUpPrefab = _powerUpPrefabs[randomIndex];
            Instantiate(selectedPowerUpPrefab, spawnPosition, Quaternion.identity);
        }
    }


    public void StopSpawningPowerUp()
    {
        _stopSpawnPowerUp = true;
    }
    
}

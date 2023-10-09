using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnManager : MonoBehaviour
{
    private bool _stopSpawn = false;

    [SerializeField] private float _enemySpawnInterval = 3.0f;
    [SerializeField] private float _decreaseIntervalAmount = 0.1f; 
    [SerializeField] private float _decreaseTime = 10.0f;
    [SerializeField] private float _asteroidSpawnIntervalMax = 60.0f;
    [SerializeField] private float _asteroidSpawnIntervalMin = 25.0f;

    [SerializeField] private GameObject _enemyPrefab;
    [SerializeField] private GameObject _enemyFirePrefab;
    [SerializeField] private GameObject _asteroidPrefab;
    [SerializeField] private GameObject _enemyContainer;
    


    void Start()
    {
        InvokeRepeating("SpawnEnemy", 2.0f, _enemySpawnInterval);
        InvokeRepeating("SpawnEnemy", 45.0f, _enemySpawnInterval);
        InvokeRepeating("SpawnEnemy", 120.0f, _enemySpawnInterval);
        InvokeRepeating("SpawnAsteroid", 5.0f, Random.Range(_asteroidSpawnIntervalMin, _asteroidSpawnIntervalMax));
        StartCoroutine(IncreaseSpawnRoutine());
    }

    
    private void SpawnAsteroid()
    {
        if (_stopSpawn == false)
        {
            Vector3 spawnPosition = new Vector3(Random.Range(-10.0f, 10.0f), 7.6f, 0.0f);
            GameObject newAsteroid = Instantiate(_asteroidPrefab, spawnPosition, Quaternion.identity);
            newAsteroid.transform.parent = _enemyContainer.transform;
        }
    }


    private void SpawnEnemy()
    {
        if (_stopSpawn == false)
        {
            Vector3 spawnPosition = new Vector3(Random.Range(-10.0f, 10.0f), 7.6f, 0.0f);
            GameObject newEnemy = Instantiate(_enemyPrefab, spawnPosition, Quaternion.identity);
            newEnemy.transform.parent = _enemyContainer.transform;
        }
    }


    private IEnumerator IncreaseSpawnRoutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(_decreaseTime);
            DecreaseSpawnInterval();
        }
    }


    private void DecreaseSpawnInterval()
    {
        _enemySpawnInterval -= _decreaseIntervalAmount;
        if (_enemySpawnInterval < 0.1f)
            _enemySpawnInterval = 0.1f;
    }


    public void StopSpawning()
    {
        _stopSpawn = true;
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class controller : MonoBehaviour
{
    Rigidbody r;
    bool grounded = false;
    // Start is called before the first frame update
    void Start()
    {
        r = transform.gameObject.GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Jump();
        }
        else if (grounded == false)
        {
            r.AddForce(new Vector3(0f, -9.8f, 0f));
        }


        
    }

    void Jump()
    {
        r.AddForce(Vector3.up * 50f);
    }
}

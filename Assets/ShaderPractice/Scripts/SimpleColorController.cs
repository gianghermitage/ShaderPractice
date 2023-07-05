using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleColorController : MonoBehaviour
{
    public ComputeShader m_shader;

    public RenderTexture m_mainTex;

    private int m_textSize = 256;

    private Renderer m_rend;

    // Start is called before the first frame update
    void Start()
    {
        m_mainTex = new RenderTexture(m_textSize, m_textSize, 0, RenderTextureFormat.ARGB32);
        m_mainTex.enableRandomWrite = true;
        m_mainTex.Create();

        m_rend = GetComponent<Renderer>();
        m_rend.enabled = true;

        m_shader.SetTexture(0, "Result", m_mainTex);

        m_rend.material.SetTexture("_MainTex", m_mainTex);

        m_shader.Dispatch(0, 4, 4, 1);
    }

    // Update is called once per frame
    void Update()
    {
    }
}
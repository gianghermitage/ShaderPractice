using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeBufferMono : MonoBehaviour
{
    public ComputeShader m_shader;
    [Range(0.0f, 0.5f)] public float m_radius = 0.5f;
    [Range(0.0f, 1.0f)] public float m_center = 0.5f;
    [Range(0.0f, 0.5f)] public float m_smooth = 0.01f;
    public Color m_mainColor = new Color();
    private RenderTexture m_mainTex;
    private int m_textSize = 128;
    private Renderer m_rend;

    struct Circle
    {
        public float radius;
        public float center;
        public float smooth;
    }

    private Circle[] m_circle;

    private ComputeBuffer _mBuffer;

    private void Start()
    {
        CreateShaderTex();
    }

    private void Update()
    {
        SetShaderTex();
    }




    private void CreateShaderTex()
    {
        m_mainTex = new RenderTexture(m_textSize, m_textSize, 0, RenderTextureFormat.ARGB32);
        m_mainTex.enableRandomWrite = true;
        m_mainTex.Create();

        m_rend = GetComponent<Renderer>();
        m_rend.enabled = true;
    }

    private void SetShaderTex()
    {
        uint threadGroupSizeX;

        m_shader.GetKernelThreadGroupSizes(0, out threadGroupSizeX, out _, out _);
        int size = (int)threadGroupSizeX;
        m_circle = new Circle[size];

        for (int i = 0; i < size; i++)
        {
            m_circle[i].center = m_center;
            m_circle[i].smooth = m_smooth;
            m_circle[i].radius = m_radius;
        }

        //circle got 3 float, each take 4 bytes => 3 * 4 = 12
        int stride = 12;
        _mBuffer = new ComputeBuffer(size, 12, ComputeBufferType.Default);

        _mBuffer.SetData(m_circle);
        m_shader.SetBuffer(0, "CircleBuffer", _mBuffer);

        m_shader.SetTexture(0, "Result", m_mainTex);
        m_shader.SetVector("MainColor", m_mainColor);
        m_rend.material.SetTexture("_MainTex", m_mainTex);
        m_shader.Dispatch(0, m_textSize, m_textSize, 1);
        _mBuffer.Release();


    }



}

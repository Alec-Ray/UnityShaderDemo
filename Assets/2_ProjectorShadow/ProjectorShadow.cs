using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectorShadow : MonoBehaviour
{
    public float m_ProjectorSize = 10;
    public int m_RenderTexSize = 1024;
    public LayerMask m_LayerCaster;
    public LayerMask m_LayerIgnoreReceiver;
    public Transform m_FollowObj;

    private RenderTexture m_RenderTexture;
    private Projector m_Projector;
    private Camera m_Camera;

    // Start is called before the first frame update
    void Start()
    {
        //RT
        m_RenderTexture = new RenderTexture(m_RenderTexSize, m_RenderTexSize, 0, RenderTextureFormat.R8);
        m_RenderTexture.name = "ShodowRT";
        m_RenderTexture.antiAliasing = 1;
        m_RenderTexture.filterMode = FilterMode.Bilinear;
        //传递给Projector材质的RenderTexture必须是clamp模式,clamp会在Projector边界处的阴影出现长条，可用一张Mask Texture解决
        m_RenderTexture.wrapMode = TextureWrapMode.Clamp;

        //投影器设置
        m_Projector = gameObject.GetComponent<Projector>();
        m_Projector.orthographic = true;
        m_Projector.orthographicSize = m_ProjectorSize;
        m_Projector.ignoreLayers = m_LayerIgnoreReceiver;
        m_Projector.material.SetTexture("_ShadowTex", m_RenderTexture);

        //摄像机设置
        m_Camera = gameObject.AddComponent<Camera>();
        m_Camera.clearFlags = CameraClearFlags.Color;
        m_Camera.backgroundColor = Color.black;
        m_Camera.orthographic = true;
        m_Camera.orthographicSize = m_ProjectorSize;
        m_Camera.depth = -100;
        m_Camera.nearClipPlane = m_Projector.nearClipPlane;
        m_Camera.farClipPlane = m_Projector.farClipPlane;
        m_Camera.targetTexture = m_RenderTexture;

        //设置Camera渲染使用的shader
        Shader replaceShader = Shader.Find("ShaderDemo/ProjectorShadowCaster");
        m_Camera.cullingMask = m_LayerCaster;
        m_Camera.SetReplacementShader(replaceShader, "RenderType");
    }

    private void LateUpdate()
    {
        transform.position = m_FollowObj.transform.position - transform.forward * 50.0f;
    }
}

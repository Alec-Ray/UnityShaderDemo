Shader "ShaderDemo/ProjectorShadowReceive"
{
    Properties
    {
		//Projector上面的摄像机生成的RT
		_ShadowTex("Shadow Texture", 2D) = "gray"{}
		//控制阴影的强弱，远处阴影减弱
		_MaskTex ("Texture", 2D) = "white" {}
		//阴影强度
		_Intensity("Intensity", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="AlphaTest+1" }
        LOD 100

        Pass
        {
			ZWrite off
			ColorMask RGB
			Blend DstColor Zero
			Offset -1, -1

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
				float4 pos:POSITION;
				float4 sproj : TEXCOORD0;
            };

			float4x4 unity_Projector;	//投影矩阵
			sampler2D _ShadowTex;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			float _Intensity;

			v2f vert (float4 vertex:POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.sproj = mul(unity_Projector, vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//取投影的结果
				half4 shadowCol = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.sproj));
				half maskCol = tex2Dproj(_MaskTex, UNITY_PROJ_COORD(i.sproj)).r;
				half a = shadowCol.r * maskCol;
				float c = 1.0 - _Intensity * a;
				//float c = 1.0 - _Intensity * shadowCol.r;
				return c;
			}
            ENDCG
        }
    }
}

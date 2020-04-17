Shader "Unlit/PlanarShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
			
		//阴影颜色
		_ShadowColor("_ShadowColor",Color) = (0,0,0,1)
		//模板写入值
		_StencilRef("StencilRef",float) = 2
		//光源方向
		_LightDir("LightDir",vector) = (1,1,1,1)
		//地面，前三个向量为地面法线
		[HideInInspector]
		_Plane("Plane",vector) = (0,1,0,0)
		//地面上随机的一个点
		[HideInInspector]
		_RandomPoint("RandomPoint",vector) = (0,0.001,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }

		Pass
		{
			Stencil
			{
				Ref[_StencilRef]
				Comp NotEqual
				Pass replace
			}
			Zwrite Off
			Blend srcalpha oneminussrcalpha
			//避免z-fitting
			Offset -1,-1
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			struct appdata
			{
				float4 vertex:POSITION;
			};

			struct v2f
			{
				float4 pos:POSITION;
			};

			fixed4 _ShadowColor;
			half4 _Plane;
			half4 _LightDir;
			half4 _RandomPoint;

			v2f vert(appdata v)
			{
				v2f o;
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				//W:顶点位置
				//T:矢量
				//L:光源方向
				//R:地面上一点
				//N:地面的法线
				//P:最终的投影点
				// P = W + T*L
				//(W + T*L- R).N = 0
				//T = ((R - W).N)/(L.N)
				//float4 lightDir = normalize(_WorldSpaceLightPos0);
				float t = dot(_RandomPoint.xyz - worldPos.xyz, _Plane.xyz) / dot(_LightDir.xyz, _Plane.xyz);
				worldPos.xyz = worldPos.xyz + t * _LightDir.xyz;
				o.pos = mul(unity_MatrixVP, worldPos);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				return _ShadowColor;
			}
			ENDCG
		}
    }
	//FallBack "Diffuse"
}

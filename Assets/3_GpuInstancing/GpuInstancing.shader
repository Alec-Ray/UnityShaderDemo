Shader "ShaderDemo/GpuInstancing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
			//声明Instancing编译选项
			#pragma multi_compile_instancing
            #include "UnityCG.cginc"
			
			//PS:SkinMeshRenderer不支持GpuInstancing,可以考虑使用官方的AnimatioInstancing
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

				//顶点的输入结构体需要有一个instance ID.
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

				//顶点的输出结构体需要有一个instance ID.
				UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
				//使Shader可以访问instance ID，注意这个必须顶点着色器的开头
				UNITY_SETUP_INSTANCE_ID(v);

				//将instance ID从输入结构体加入到输出结构体，可以让你在片段着色器中访问此实例的数据
				//UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//使Shader可以访问instance ID，对于片段着色器来说，不是必须要写的
				//UNITY_SETUP_INSTANCE_ID(i);

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}

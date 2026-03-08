Shader "UI/ShineWithDelay"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _ShineColor ("Shine Color", Color) = (1,1,1,1)
        _Width ("Shine Width", Range(0.01,0.5)) = 0.2
        _Speed ("Speed", Float) = 1
        _Angle ("Angle", Range(0,1)) = 0.5
        _Delay ("Delay After Shine", Float) = 2
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _ShineColor;
            float _Width;
            float _Speed;
            float _Angle;
            float _Delay;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = IN.uv;
                OUT.color = IN.color;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                float2 uv = IN.uv;

                half4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv) * IN.color;

                float cycle = 1.0 + _Delay;

                float time = frac(_Time.y * _Speed / cycle) * cycle;

                float shine = 0;

                if(time < 1.0)
                {
                    float t = time;
                    float diag = uv.x + uv.y * _Angle;

                    shine = smoothstep(t-_Width, t, diag) -
                            smoothstep(t, t+_Width, diag);
                }

                col.rgb += _ShineColor.rgb * shine;

                return col;
            }

            ENDHLSL
        }
    }
}
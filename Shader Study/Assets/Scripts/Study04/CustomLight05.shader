Shader "Custom/CustomLight05"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normalmap",2d) = "bump"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Test// Test가 라이트 이름

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Alpha = c.a;
        }
        float4 LightingTest(SurfaceOutput s, float LightDir, float atten) //"Lighting"+(라이트이름)=함수이름
        {
            //float ndotl = dot(s.Normal, LightDir);
            float ndotl = saturate(dot(s.Normal, LightDir));//이 안의 값을 01사이로 잘라줌.
            /*
            float ndotl = max(0,dot(s.Normal, LightDir))
            위의 값과 비슷한 결과를 내놓는데 max는 큰 값을 제한하지 않음.
            */
            float4 final;
            final.rgb = ndotl * s.Albedo * _LightColor0.rgb * atten;//atten은 빛의 감쇠현상을 시뮬레이트한다.
            //atten이 없으면 self shadow가 생기지 않는다. receive shadow가 작동하지 않아 다른물체가 이 얼굴에 그림자를 드리우지 않는다.
            //그전의 ndotl연산은 조명의 노멀의 각도를 표현만 한것이고 _LightColor0.rgb는 조명의 색상이나 강도는 이 내장변수를 이용해 조명의 색상과 강도를 가져온다.
            final.a = s.Alpha;
            return final;
        }

        ENDCG
    }
    FallBack "Diffuse"
}

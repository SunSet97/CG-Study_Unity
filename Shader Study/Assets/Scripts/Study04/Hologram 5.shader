Shader "Custom/Hologram5"
{
    Properties
    {
        _BumpMap("NormalMap", 2D) = "bump" {}
        _TimeSpeed("Time Speed",Range(0.1,10)) = 1
    }
        SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue"="Transparent"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight noambient alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _BumpMap;
        float _TimeSpeed;
        struct Input
        {
            float2 uv_BumpMap;
            float3 viewDir;//버텍스에서 바라보는 카메라의 방향, LightDir는 버텍스에서 바라보는 조명의 방향
            float3 worldPos;
        };


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            //o.Albedo = c.rgb;
            o.Emission = float3(0,1,0);//pow는 흰 부분을 줄이기 위해서. 라인의 간격을 좁히기 위해 3배 곱함. 위로 흘러가게 만들기 위해 시간을 뻄
            //y축만 필요해서, frac()는 숫자의 소수점부분만 반환.
            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = pow(1 - rim,3)+ pow(frac(IN.worldPos.g * 3 - _Time.y), 30);//3제곱
            o.Alpha = rim*abs(sin(_Time.y* _TimeSpeed));//모든 음수를 양수로 변화시킴, 통통튀는 느낌이 듦.
        }
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) 
        {
            return float4(0, 0, 0, s.Alpha);//알파를 제외한 아무것도 리턴하지 않음. lambert연산이 필요없어서.
        }
        ENDCG
    }
        FallBack "Transparent/Diffuse"//그림자를 생성하지 않게 만드는 코드
}

Shader "Custom/Alpha2Pass"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normalmap",2d) = "bump"{}

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        //1st pass zwrite on, rendering off
        //z버퍼에 그리되 화면에는 그리지 않음. Z버퍼에만 그리는 패스를 그림. 이 코드는 모든 variants를 최소한으로 줄이고 최대한 계싼을 줄인 코드.
        ZWrite on
        ColorMask 0 //이 명령어는 쉐이더의 결과를 보이지 않도록 함.
        CGPROGRAM
        #pragma surface surf nolight noambient noforwardadd nolightmap novertexlights noshadow
        #pragma target 3.0
        struct Input
        {
            float4 color:Color;           
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
        }
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0,0,0,0);
        }
        ENDCG

        //2nd pass zwrite off, rendering on
        //Z버퍼에 그리지 않고 그림. 평범한 반투명. 이미 존재하는 Z버퍼에 가려진 부분은 그리지 않음! 그래서 꺠끗한 반투명이 그려진다. 뒷면을 안그리게 함.
        //머리카락을 알파 블렌딩으로 표현할 때도 가능함.
        ZWrite off
        CGPROGRAM
        #pragma surface surf Lambert alpha:fade
        sampler2D _MainTex;
        sampler2D _BumpMap;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };
        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c=tex2D(_MainTex,IN.uv_MainTex);
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            o.Albedo=c.rgb;
            o.Alpha=0.5;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

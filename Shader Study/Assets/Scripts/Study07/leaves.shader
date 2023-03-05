Shader "Custom/leaves"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normalmap",2D) = "bump"{}
        _Cutoff ("Cutoff", float) = 0.5
        _Move("Move",Range(0,0.5))=0.1
        _Timing("Timing",Range(0,5))=1

    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alphatest:_Cutoff vertex:vert addshadow
        //addshadow를 하면 버텍스에 적용한 애니메이션 데이터를 그림자 패스에 전달한다.

        // Use shader model 3.0 target, to ge   t nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _Move;
        float _Timing;

        void vert(inout appdata_full v)
        {
            v.vertex.y += sin(_Time.y * _Timing)*_Move*v.color.r;
            //빨간 부분만 움직이도록 만듦.
        }


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
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            o.Albedo = c.rgb;
            o.Alpha=c.a;
                
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/Cutout/VertexLit"
}

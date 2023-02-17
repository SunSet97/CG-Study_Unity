Shader "Custom/Fresnel_outline"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("NormalMap",2D)="bump"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        //cull back 뒷면을 그리지 않음. 대부분 자동으로 됨.
        cull back//면 뒤집어짐

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Toon

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_BumpMap;
            float2 uv_MainTex;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        float4 LightingToon(SurfaceOutput s, float3 lightDir,float3 viewDir, float atten)
        {
            float ndotl=dot(s.Normal,lightDir)*0.5+0.5;
            /*if(ndotl>0.5)
            {
                ndotl=1;
            }
            else
            {
                ndotl=0.3;
            }*/
            ndotl=ndotl*3;
            ndotl=ceil(ndotl)/3;//ceil은 정수로 만들어 주는 함수//5단계로 나눔

            float rim=abs(dot(s.Normal,viewDir));
            if(rim>0.5)
            {
                rim=1;
            }
            else
            {
                rim=-1;//0으로 하면 ambient color가 더해지면 검은선이 밝아져서 그걸 막으려고
            }
            float4 final;
            final.rgb=s.Albedo*ndotl*_LightColor0.rgb*rim;
            final.a=s.Alpha;
            return final;

        }
        ENDCG
    }
    FallBack "Diffuse"
}

Shader "Custom/Water_test"
{
    Properties
    {
        _CubeMap("CubeMap",cube)=""{}
        _MainTex("MainTex",2D)="white"{}
        _BumpMap ("Water Bump", 2D) = "bump" {}
        _BumpMap2 ("Water Bump2", 2D) = "bump" {}
        _SpacPow ("Specular",float)=2
        _WaveSpeed("Wave Speed", float) = 0.05
        _WavePower("Wave Power", float) = 0.2
        _WaveTilling("Wave Tilling", float) = 25
    }
    /*CGINCLUDE
        #define _GLOSSYENV 1
        #define UNITY_SETUP_BRDF_INPUT SpecularSetup
    ENDCG*/
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 200
        GrabPass{}
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf WLight vertex:vert
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _BumpMap,_BumpMap2;
        sampler2D _MainTex,_GrabTexture;
        samplerCUBE _CubeMap;
        float _WaveSpeed;
        float _WavePower;
        float _WaveTilling;
        float _SpacPow;
        float dotData;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_BumpMap2;
            float3 worldRefl;
            float3 viewDir;
            float4 screenPos;
            INTERNAL_DATA
        };

        void vert(inout appdata_full v)
        {
            v.vertex.y+=sin((abs(v.texcoord.x*2-1)*_WaveTilling)+sin(_Time.y*1))*_WavePower;//abs함수로 감싸면 -1~0~1이 1~0~1으로 바뀌면서 지그재그 됨.

        }
        

        
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        void surf (Input IN, inout SurfaceOutput o)
        {
            
	        float3 fNormal1=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap+float2(_Time.y*_WaveSpeed,0.0f)));
            float3 fNormal2=UnpackNormal(tex2D(_BumpMap2,IN.uv_BumpMap-float2(_Time.y*_WaveSpeed,0.0f)));
            o.Normal=(fNormal1+fNormal2)/2;
        
	        //o.Albedo = float3(1,1,1);
            //Noise 
            float4 fNoise=tex2D(_MainTex,IN.uv_MainTex+_Time.x);
            //reflection
            float3 fRefl = texCUBE(_CubeMap,WorldReflectionVector(IN,o.Normal));//sky
            float4 reflection = tex2D(_GrabTexture, (IN.screenPos.xy/IN.screenPos.a).xy+(o.Normal.xy*0.03)+(fNoise.r*0.05));
            dotData=pow( saturate(1-dot(o.Normal, IN.viewDir)), 0.6);
            float3 water = lerp(reflection, fRefl, dotData).rgb;
            o.Albedo=water;
            //o.Albedo = reflection.rgb;
            /*
            //rim
            float frim=dot(o.Normal,IN.viewDir);
            frim=saturate(pow((1-frim),3));
            //grab
            
            //float3 scrPos=IN.screenPos.xyz/(IN.screenPos.w+0.0000001);
            //ref
            float3 fGrab=tex2D(_GrabTexture, (IN.screenPos/IN.screenPos.a).xy + o.Normal.xy*0.03*fNoise);//(_GrabTexture,scrPos.xy+fNoise.r*0.05);
            dotData=pow(saturate(1-dot(o.Normal,IN.viewDir)),0.6);
            */
            
            //o.Gloss=1;  
            //o.Specular=1;
            
            //float3 water=lerp(fGrab,fRefl,pow(dot(o.Normal,IN.viewDir),dotData)).rgb;
            //o.Emission=lerp(fGrab,fRefl,frim);
            //o.Emission=water;

            
        }
        
        float4 LightingWLight(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        {
            float3 refVec=s.Normal*dot(s.Normal,viewDir)*2-viewDir;
            refVec = normalize(refVec);
            float spcr=lerp(0,pow(saturate(dot(refVec,lightDir)),256),dotData)*_SpacPow;
            return float4(s.Emission+spcr.rrr,1);
            
        
        }
        ENDCG
    }
    FallBack "Diffuse"
}

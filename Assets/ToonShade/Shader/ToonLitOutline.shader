﻿Shader "GenshinLikeToonShader"
{
    Properties
    {
        [Header(High Level Setting)]
        [ToggleUI]_IsFace("Is Face? (please turn on if this is a face material)", Float) = 0

        [Header(Main Texture Setting)]
        [Space(5)]
        [MainTexture]_BaseMap ("Base Map (Albedo)", 2D) = "black" { }
        [MainColor]_BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _WorldLightInfluence ("World Light Influence", range(0.0, 1.0)) = 0.1
        _BumpMap("NormalMap", 2D) = "white" {}
        _BumpScale("Normal Scale", float) = 1
        [Space(30)]

        [Header(Emission)]
        [Toggle(ENABLE_EMISSION)]_EnableEmission ("Enable Emission", Float) = 0
        _Emission ("Emission", range(0.0, 20.0)) = 1.0
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissionColor ("Emission Color", color) = (0, 0, 0, 0)
        [HideInInspector]_EmissionBloomFactor ("Emission Bloom Factor", range(0.0, 10.0)) = 1.0
        [HideInInspector]_EmissionMapChannelMask ("Emission Map Channel Mask", Vector) = (1, 1, 1, 0)
        [Space(30)]
        
        
        [Header(Shadow Setting)]
        [Space(5)]
        _ShadowMultColor ("Shadow Color", color) = (1.0, 1.0, 1.0, 1.0)
        _ShadowArea ("Shadow Area", range(0.0, 1.0)) = 0.5
        _ShadowSmooth ("Shadow Smooth", range(0.0, 1.0)) = 0.05
        [HideInInspector]_LightMap ("LightMap", 2D) = "grey" { }
        [Space(30)]

        [Header(Shadow mapping)]
        _ReceiveShadowMappingAmount("Shadow Mapping Amount", Range(0,1)) = 0.65
        _ReceiveShadowMappingPosOffset("Shadow Bias", Float) = 0
        _ShadowMapColor("Shadow Map Color", Color) = (1,0.825,0.78)
        [Space(30)]


        [Header(Specular Setting)]
        [Space(5)]
        [Toggle]_EnableSpecular ("Enable Specular", float) = 1
        [HDR]_LightSpecColor ("Specular Color", color) = (0.8, 0.8, 0.8, 1)
        _Shininess ("Shininess", range(0.1, 20.0)) = 10.0
        _SpecSmoothness("SpecSmoothness", range(0, 0.1)) = 0
        _SpecMulti ("Mult Factor", range(0.1, 1.0)) = 1
        [Toggle(ENABLE_METAL_SPECULAR)] _EnableMetalSpecular ("Enable Metal Specular", float) = 1
        [Header(HighLightMask)]
        [Toggle(ENABLE_SPECULAR_MAP)] _EnableSpecularMap ("Enable Specular map", float) = 1
        _Set_HighColorMask ("HighLightMask", 2D) = "white" {}
        [Space(30)]

        [Header(RimLight Setting)]
        [Space(5)]
        [Toggle]_EnableLambert ("Enable Lambert", float) = 1
        [Toggle]_EnableRim ("Enable Rim", float) = 1
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimSmooth ("Rim Smooth", Range(0.001, 1.0)) = 0.01
        //_RimLightBlend("RimLightBlend", float) = 0.5
        //_RimLightBlendPoint("RimLightBlend Point", float) = 0.5
        _RimWidth("Rim Width", float) = 0.1
        _RimMask("Rim Mask", 2D) = "white" {}
        [Space(30)]

        [Header(Outline Setting)]
        [Space(5)]
        _OutlineWidth ("_OutlineWidth (World Space)", Range(0, 4)) = 1
        _OutlineColor ("Outline Color", color) = (0.5, 0.5, 0.5, 1)
        _OutlineZOffset ("Outline Z Offset (View Space)", Range(0, 1)) = 0.0001

        [Header(Alpha)]
        [Toggle(ENABLE_ALPHA_CLIPPING)]_EnableAlphaClipping ("_EnableAlphaClipping", Float) = 0
        _Cutoff ("Cutoff (Alpha Cutoff)", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "UniversalMaterialType" = "Lit" "Queue" = "Geometry" }

        HLSLINCLUDE
        #pragma shader_feature_local_fragment _UseAlphaClipping
        ENDHLSL

        Pass
        {
            NAME "TOON_BASE_PASS"

            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZTest LEqual
            ZWrite On
            Blend One Zero

            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            
            // #pragma shader_feature_local ENABLE_AUTOCOLOR
            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING
            #pragma shader_feature_local_fragment ENABLE_BLOOM_MASK
            #pragma shader_feature_local_fragment ENABLE_FACE_SHADOW_MAP
            #pragma shader_feature_local_fragment ENABLE_SPECULAR_MAP
            #pragma shader_feature_local_fragment ENABLE_EMISSION
            
            #pragma vertex ToonPassVertex
            #pragma fragment ToonPassFragment
            #define SHADOWS_SCREEN 1

            #include "ToonLitForward.hlsl"
            
            ENDHLSL

        }
        Pass
        {
            Name "TOON_OUTLINE_PASS"
            Tags { "LightMode" = "SRPDefaultUnlit"  }
            Cull Front
            HLSLPROGRAM

            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING

            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment
            #define _ADDTIONAL_LIGHTS

            #include "ToonLitForward.hlsl"


            ENDHLSL

        }
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM
            #pragma enable_d3d11_debug_symbols
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ToonPassVertex
            #pragma fragment FragmentAlphaClip
            #define SHADOWS_SCREEN 1

            #include "ToonLitForward.hlsl"
            ENDHLSL

        }
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment FragmentAlphaClip
            
            #include "ToonLitForward.hlsl"
            ENDHLSL

        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
    
    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
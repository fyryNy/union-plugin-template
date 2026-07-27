function(generate_ipp_translation_units out_variable)
    set(ipp_translation_units "")

    file(GLOB_RECURSE IppFiles
        "src/*.ipp"
    )

    set(GothicEngines "")

    if(GOTHIC_API_G1)
        list(APPEND GothicEngines G1 Gothic_I_Classic)
    endif()

    if(GOTHIC_API_G1A)
        list(APPEND GothicEngines G1A Gothic_I_Addon)
    endif()

    if(GOTHIC_API_G2)
        list(APPEND GothicEngines G2 Gothic_II_Classic)
    endif()

    if(GOTHIC_API_G2A)
        list(APPEND GothicEngines G2A Gothic_II_Addon)
    endif()

    while(GothicEngines)
        list(POP_FRONT GothicEngines PlatformSuffix GothicNamespace)

        string(TOLOWER "${PlatformSuffix}" platform_suffix_lowercase)

        foreach(ipp ${IppFiles})
            # Extract filename (no extension)
            get_filename_component(filename ${ipp} NAME_WE)

            # Append platform suffix to filename
            set(filename "${filename}_${platform_suffix_lowercase}")

            # Output file path
            set(out "${CMAKE_CURRENT_BINARY_DIR}/src/generated_ipp/${filename}.cpp")

            # Tell configure_file what to substitute
            set(IppFile ${ipp})

            # Generate the .cpp file
            configure_file(
                    ${CMAKE_CURRENT_SOURCE_DIR}/src/IppFileTemplate.in
                    ${out}
                    @ONLY
            )

            list(APPEND ipp_translation_units ${out})
        endforeach()
    endwhile()

    set(${out_variable} ${ipp_translation_units} PARENT_SCOPE)
endfunction()
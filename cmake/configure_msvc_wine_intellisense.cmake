function(configure_msvc_wine_intellisense target union_target)
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"
       OR NOT CMAKE_EXPORT_COMPILE_COMMANDS)
        return()
    endif()

    file(GLOB_RECURSE _editor_ipp_files CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/src/*.ipp"
    )

    if(_editor_ipp_files)
        set(_editor_context_header
            "${CMAKE_BINARY_DIR}/intellisense/IntelliSenseContext.h"
        )
        file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/intellisense")
        file(GENERATE
            OUTPUT "${_editor_context_header}"
            CONTENT [=[#pragma once
#include <Union/Hook.h>
#include <ZenGin/zGothicAPI.h>
]=]
        )

        set(_editor_engines "")
        if(GOTHIC_API_G1)
            list(APPEND _editor_engines
                g1 Gothic_I_Classic Engine_G1
            )
        endif()
        if(GOTHIC_API_G1A)
            list(APPEND _editor_engines
                g1a Gothic_I_Addon Engine_G1A
            )
        endif()
        if(GOTHIC_API_G2)
            list(APPEND _editor_engines
                g2 Gothic_II_Classic Engine_G2
            )
        endif()
        if(GOTHIC_API_G2A)
            list(APPEND _editor_engines
                g2a Gothic_II_Addon Engine_G2A
            )
        endif()

        while(_editor_engines)
            list(POP_FRONT _editor_engines
                _editor_suffix _editor_namespace _editor_engine
            )
            set(_editor_target "${target}_intellisense_${_editor_suffix}")

            add_library("${_editor_target}" OBJECT EXCLUDE_FROM_ALL
                ${_editor_ipp_files}
            )
            set_source_files_properties(${_editor_ipp_files}
                PROPERTIES LANGUAGE CXX
            )
            target_include_directories("${_editor_target}" BEFORE PRIVATE
                "${CMAKE_SOURCE_DIR}/userapi"
                "${CMAKE_SOURCE_DIR}/src"
                "${CMAKE_SOURCE_DIR}/signatures"
            )
            target_compile_definitions("${_editor_target}" PRIVATE
                "GOTHIC_NAMESPACE=${_editor_namespace}"
                "ENGINE=${_editor_engine}"
            )
            target_compile_options("${_editor_target}" PRIVATE
                "/FI${_editor_context_header}"
            )
            target_link_libraries("${_editor_target}" PRIVATE
                "${union_target}"
            )
        endwhile()
    endif()

    set(_editor_compile_commands "${CMAKE_SOURCE_DIR}/compile_commands.json")

    if(IS_SYMLINK "${_editor_compile_commands}")
        file(REMOVE "${_editor_compile_commands}")
    elseif(EXISTS "${_editor_compile_commands}")
        message(FATAL_ERROR
            "${_editor_compile_commands} exists and is not a symlink.")
    endif()

    file(CREATE_LINK
        "${CMAKE_BINARY_DIR}/compile_commands.json"
        "${_editor_compile_commands}"
        SYMBOLIC
        RESULT _editor_compile_commands_result
    )

    if(NOT _editor_compile_commands_result STREQUAL "0")
        message(FATAL_ERROR
            "Could not select the active editor compilation database: "
            "${_editor_compile_commands_result}")
    endif()
endfunction()

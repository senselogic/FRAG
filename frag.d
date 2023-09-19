/*
    This file is part of the Frag distribution.

    https://github.com/senselogic/FRAG

    Copyright (C) 2020 Eric Pelzer (ecstatic.coder@gmail.com)

    Frag is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Frag is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Frag.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import core.time : msecs, Duration;
import std.conv : to;
import std.datetime : SysTime;
import std.file : dirEntries, exists, getAttributes, getTimes, mkdir, mkdirRecurse, read, readText, remove, rmdir, setAttributes, setTimes, write, PreserveAttributes, SpanMode;
import std.path : absolutePath, baseName, dirName, globMatch;
import std.stdio : writeln, File;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith, stripRight, toLower;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

long GetByteCount(
    string argument
    )
{
    long
        byte_count,
        unit_byte_count;

    argument = argument.toLower();

    if ( argument == "all" )
    {
        byte_count = long.max;
    }
    else
    {
        if ( argument.endsWith( 'b' ) )
        {
            unit_byte_count = 1;

            argument = argument[ 0 .. $ - 1 ];
        }
        else if ( argument.endsWith( 'k' ) )
        {
            unit_byte_count = 1024;

            argument = argument[ 0 .. $ - 1 ];
        }
        else if ( argument.endsWith( 'm' ) )
        {
            unit_byte_count = 1024 * 1024;

            argument = argument[ 0 .. $ - 1 ];
        }
        else if ( argument.endsWith( 'g' ) )
        {
            unit_byte_count = 1024 * 1024 * 1024;

            argument = argument[ 0 .. $ - 1 ];
        }
        else
        {
            unit_byte_count = 1;
        }

        byte_count = argument.to!long() * unit_byte_count;
    }

    return byte_count;
}

// ~~

string GetPhysicalPath(
    string path
    )
{
    version( Windows )
    {
        if ( path.length > 260 )
        {
            return `\\?\` ~ path.absolutePath;
        }
    }

    return path;
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

string GetFolderPath(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ 0 .. slash_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

string GetFileName(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ slash_character_index + 1 .. $ ];
    }
    else
    {
        return file_path;
    }
}

// ~~

bool IsEmptyFolder(
    string folder_path
    )
{
    bool
        it_is_empty_folder;

    try
    {
        it_is_empty_folder = true;

        foreach ( folder_entry; dirEntries( folder_path, SpanMode.shallow ) )
        {
            it_is_empty_folder = false;

            break;
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't read folder : " ~ folder_path, exception );
    }

    return it_is_empty_folder;
}

// ~~

void CreateFolder(
    string folder_path
    )
{
    try
    {
        if ( folder_path != ""
             && folder_path != "/"
             && !folder_path.exists() )
        {
            writeln( "Creating folder : ", folder_path );

            folder_path.GetPhysicalPath().mkdirRecurse();
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void RemoveFolder(
    string folder_path
    )
{
    writeln( "Removing folder : ", folder_path );

    try
    {
        folder_path.GetPhysicalPath().rmdir();
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void RemoveFile(
    string file_path
    )
{
    writeln( "Removing file : ", file_path );

    try
    {
        file_path.GetPhysicalPath().remove();
    }
    catch ( Exception exception )
    {
        Abort( "Can't remove file : " ~ file_path, exception );
    }
}

// ~~

ubyte[] ReadByteArray(
    string file_path
    )
{
    ubyte[]
        file_byte_array;

    writeln( "Reading file : ", file_path );

    try
    {
        file_byte_array = cast( ubyte[] )file_path.GetPhysicalPath().read();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_byte_array;
}

// ~~

void WriteByteArray(
    string file_path,
    ubyte[] file_byte_array
    )
{
    CreateFolder( file_path.GetPhysicalPath().GetFolderPath() );

    writeln( "Writing file : ", file_path );

    try
    {
        file_path.write( file_byte_array );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.GetPhysicalPath().readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    CreateFolder( file_path.GetFolderPath() );

    writeln( "Writing file : ", file_path );

    try
    {
        file_path.GetPhysicalPath().write( file_text );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

void WriteFile(
    string output_file_path,
    string output_file_text,
    long output_file_index
    )
{
    long
        dot_character_index;

    dot_character_index = output_file_path.lastIndexOf( '.' );

    output_file_path
        = output_file_path[ 0 .. dot_character_index ]
          ~ '.'
          ~ ( output_file_index + 1 ).to!string()
          ~ output_file_path[ dot_character_index .. $ ];

    output_file_path.WriteText( output_file_text );
}

// ~~

void SplitFile(
    string input_file_path,
    long maximum_byte_count
    )
{
    long
        output_file_index;
    string
        input_file_text,
        output_file_line,
        output_file_text;
    string[]
        input_file_line_array;

    output_file_index = 0;

    input_file_text = ReadText( input_file_path );
    input_file_line_array = input_file_path.split( ";\n" );

    foreach ( input_file_line_index, input_file_line; input_file_line_array )
    {
        if ( input_file_line_index < input_file_line_array.length - 1 )
        {
            output_file_line = input_file_line ~ ";\n";
        }

        if ( output_file_line.length < maximum_byte_count )
        {
            if ( output_file_text.length + output_file_line.length <= maximum_byte_count )
            {
                output_file_text ~= output_file_line;
            }
            else
            {
                WriteFile( input_file_path, output_file_text, output_file_index );

                output_file_text = output_file_line;
                ++output_file_index;
            }
        }
        else
        {
            Abort( "Line too long : " ~ output_file_line );
        }
    }

    if ( output_file_text != "" )
    {
        WriteFile( input_file_path, output_file_text, output_file_index );
    }
}

// ~~

void SplitFiles(
    string[] input_file_path_array,
    long maximum_byte_count
    )
{
    foreach ( input_file_path; input_file_path_array )
    {
        SplitFile( input_file_path, maximum_byte_count );
    }
}

// ~~

void JoinFiles(
    string[] input_file_path_array,
    string output_file_path
    )
{
    string
        output_file_text;

    foreach ( input_file_path; input_file_path_array )
    {
        output_file_text ~= ReadText( input_file_path );

        if ( !output_file_text.endsWith( '\n' ) )
        {
            output_file_text ~= '\n';
        }
    }

    output_file_path.WriteText( output_file_text );
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--split"
             && argument_array.length >= 2 )
        {
            SplitFiles( argument_array[ 1 .. $ ], GetByteCount( argument_array[ 0 ] ) );

            argument_array = [];
        }
        else if ( option == "--join"
             && argument_array.length >= 2 )
        {
            JoinFiles( argument_array[ 0 .. $ - 1 ], argument_array[ $ - 1 ] );

            argument_array = [];
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length > 0 )
    {
        writeln( "Usage :" );
        writeln( "    frag [options]" );
        writeln( "Options :" );
        writeln( "    --split <size> <file_path>" );
        writeln( "    --join" );
        writeln( "Examples :" );
        writeln( "    frag --split 50m" );
        writeln( "    frag --join" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}

Templator
=========

Description
-----------
Templator is a command line tool allowing to generate text documents from templates written 
in the [ERB](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html) template language.

It also provides a Domain Specific Language, the _Parameter DSL_, to define a set of parameters
that can be referenced from template files in order to generate the target document
with expected values.

Templator is developped in Ruby. It requires Ruby 1.8.7 and higher, or any version of the 1.9 branch.

Installation
------------

To quickly install Templator, use the following command:

    gem install templator

Usage
-----

The following command allows to display the online help:

    $ templator help

Two tasks are available from the command line:

 * __gen__ 

This task is responsible for the transformation of a given template to a target document, 
taking into account any provided parameter files.

Here is the most simple command line invokation.
    
    $ templator gen path/to/template path/to/target

If parameters are defined in some files, they can be passed to the template with the __-p__ switch:

    $ templator gen path/to/template path/to/target -p path/to/paramaters1 path/to/parameters2

As shown in this example, the parameters can live in multiple files. The parameter files are parsed
in the same order they are provided in the command line.

The __-c__ switch allows to define a default context from which Templator will try to
resolve parameter names that are not fully qualified in the template. More details are provided
at the end of this document.


 * __get_param__

This task allows to get the value of a parameter from the provided parameter files.

    $ templator get_param 'my_parameter' -p path/to/parameters 

Parameter DSL
-------------

The set of parameters is expressed in a Ruby DSL that provides following methods:

 * __export__

This method allows to define new parameters and make them visible from a template during
the generation process. Following example shows how to define the parameter 'my_parameter' with
the value 'my_value'

    export "my_parameter" => "my_value"

It is also possible to define several parameters in a single export line:

    export "my_parameter" => "my_value", "my_other_parameter" => "my_other_value"


It is worth noting that parameter names can be a Ruby Symbol:

    export :my_parameter => "my_value"

More over, the parameter value can be any Ruby valid expression, for example:

    export :integer => 3
    export :now => Time.now
    export :upper_parameter => "my_value".upcase

Last but not least, you can use the value of previously defined parameters to build a 
more complex parameter:

    export :parameter1 => 1
    export :parameter2 => 2
    export :sum => parameter1 + parameter2

Each time the Parameter DSL parser encounters an exported parameter, it defines 
a method with the same name. In the previous example, the value of :parameter1
and :parameter2 is gotten by invoking the corresponding methods, parameter1 et parameter2. 

 * __group__

The group method allows to define a subset of parameters.

    group :my_group {
        export :my_parameter => "my_value"
    }

Nested group is also possible:

    group :top {
        group :inner {
            ...
        }
    }

When using group, parameters have to be referenced with their fully qualified name in dot notation.

    group :foo {
        export :parameter => "foo"
    }

    group :bar {
        export :parameter = foo.first_parameter + "bar"
    }

A group can de defined in multiple places, the resulting group is a merge of all
definitions taking into account the order of the parsing:

    #file1
    group :my_group {
        export :parameter1 => 1
        export :parameter2 => 2
    }

    #file2
    group :my_group {
        export :parameter1 => 0.99999
        export :parameter3 => 3
    }

Assuming that file1 and file2 are parsed in this order, the resulting group 
is semantically equivalent to this one:

    group :my_group {
        export :parameter1 => 0.99999
        export :parameter2 => 2
        export :parameter3 => 3
    }

 * __include_group__

The include_group method is an interesting way to share some common parameters between different groups.
It allows to mix the parameters of a group in another one.
It is conceptually equivalent to the well known Ruby include method.

Consider the following example:

    group :mixin {
        export :mixme => "some value"
    }

    group :my_group {
        include_group :mixin
        export :another_parameter => "another_value"
    }

Thus, the resulting group is equivalent to :

    group :my_group {
        export :mixme => "some value"
        export :another_parameter => "another_value"
    }

Template Actions
----------------

As said before, the template language used by Templator is ERB.

In addition, the following extra methods can be invoked from a template:

 * __param__

This method allows to access the value of a parameter. 

Here is a concrete example:

File _parameters.txt_:

    group :my_group {
        export my_parameter => "my_value"
    }
    ...

File _template.txt_:

    The value of the parameter "my_parameter" defined in the group "my_group" is <%= param "my_group.my_parameter" %>

Command line invokation from the shell:
    $ templator gen template.txt output -p parameters.txt

The resulting _output_ file should have the following content:

    The value of the parameter "my_parameter" defined in the group "my_group" is my_value

 * __param_exists?__

This method tests if a parameter is defined. 
Consider the following template example:

    <% if param_exists? "my_group.my_parameter" %>
    The parameter "my_parameter" is well defined in group "my_group".
    <% else %>
    There is no parameter "my_parameter" defined in group "my_group".
    <% end %>

 * __include_file__


This method parses the content of the given file as an ERB template, 
and appends the resulting text into the output stream of the source template.

This is a convenient method to spread a template on multiple files.

Here is an example that dynamically generates the name of the template to
include according to the value of a parameter:

    blah blah blah
    <%= include_file "#{param :my_parameter}.txt"

The path of the template to include is interpreted relatively from the path
of the source template. 

Contextual resolution of parameter names

Context
-------

A context is defined with the __-c__ switch. It is eventually
used by the __param__ and __param_exists?__ methods to resolve
the provided parameter names.
Whenever the resolution of a parameter name fails, 
if a context is defined, it is prepended to the parameter name 
and a new resolution is tried with the resulting name. In this case,
you must ensure that the context matches a valid fully qualified group name.

Context is a convenient way to generate different documents from the same template,
assuming that a group of parameters is defined for each expected documents.

Here is a concrete example where the objective is to generate a Debian /etc/network/interfaces 
file for three different hosts.

File _hosts.txt_:

    group :host_a {
        export :address => "192.168.121.1"
        export :netmask => "255.255.255.0"
        export :gateway => "192.168.121.254"
    }

    group :host_b {
        export :address => "192.168.122.1"
        export :netmask => "255.255.255.0"
        export :gateway => "192.168.122.254"
    }

    group :host_c {
        export :address => "192.168.123.1"
        export :netmask => "255.255.255.0"
        export :gateway => "192.168.123.254"
    }

File _interfaces.txt_:

    iface eth0 inet static
        address <%= param :address %>
        netmask <%= param :netmask %>
        gateway <%= param :gateway %>

Command line execution from shell:

    for host in host_a host_b host_c
    do
        templator gen interfaces.txt interfaces.$host -p hosts.txt -c $host
    done

Copyright
---------

Copyright © 2011 Christophe Arguel. See LICENSE for details.

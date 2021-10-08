//          Copyright 2021 - 2024 Orfeo Da Vià
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.nodave;

public import bindbc.nodave.types;

version (BindBC_Static) version = BindNodave_Static;
version (BindNodave_Static)
   public import bindbc.nodave.bindstatic;
else
   public import bindbc.nodave.binddynamic;

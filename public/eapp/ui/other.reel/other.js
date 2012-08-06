/* <copyright>
Copyright (c) 2012, Motorola Mobility LLC.
All Rights Reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of Motorola Mobility LLC nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
</copyright> */
var Montage = require("montage/core/core").Montage,
    Component = require("montage/ui/component").Component;

// and here's a bunch of requires just to show this requiring things and upping the count in the loader
/*
require("montage/ui/condition.reel");
require("montage/ui/list.reel");
require("montage/ui/scroller.reel");
require("montage/ui/bluemoon/tabs.reel");
require("montage/ui/textarea.reel");
require("montage/ui/input-text.reel");
*/

exports.Other = Montage.create(Component, {
	aditivo: {value: "mmmmmm"}
});

/*
De todas formas haría falta cuatro pestañas en la página principal. El buscador en el centro de la página , arriba tres pestañas ("Info", "adiciones" y "links") y en un lateral, "listado".

1- info: al entrar a info habría tres bloques: "legislacion", "tipos de aditivos" y "usos" 
2 - adiciones: "fabricantes", "estudios" y "noticias"
3 -  links (links del "listado" y "otros")
4 - listado. he pensado que debería ser bastante visual porque hay mucha información y si no no invita a leerla,
así que sería guay que pudieran ir pasaándose los links de cada página (dentro de la información de cada aditivo), con una imagen, una pequeña descripción y que se pueda clickar o pasar a la siguiente página con el siguiente link



*/

/*
NestedForms v1.0
Author: Jason Kulatunga

Fixes issues with nested forms in sitecore and asp.net. 
To use make the following changes to the form embed code:

-change the <form/> tag to a  <div/>
-add a data-toggle="form" attribute to the new div
-prepend the "data-" string to all the old form attributes

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// example

<form action="http://www.example.com" method="get">
    <input type="text" name="testParam">
    <input type="submit" id="submitBtn" value="Submit" />
</form>

becomes:

<div data-toggle="form" data-action="http://www.example.com" data-method="get">
    <input type="text" name="testParam">
    <input type="submit" id="submitBtn" value="Submit" />
</div>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Now just include the script on the page and watch it work. 

The options are:

var options = {};
options.validator = function($formEle){
//return true for valid form, false for invalid form that shoudl not be submitted. 
}

*/


(function ($) {
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Submit Method
    // 

    function submitForm($this, data) {
        if (data.options.validator($this)) {

            var $form = $('<form/>')
                .attr('accept', data.accept)
                .attr('acceptCharset', data.acceptCharset)
                .attr('action', data.action)
                .attr('enctype', data.enctype)
                .attr('method', data.method)
                .attr('name', data.name)
                .attr('novalidate', data.novalidate)
                .attr('target', data.target)
                .hide();


            $this.clone(true, true).appendTo($form);
            $form.appendTo('body');
            $form.submit();
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Plugin Logic + Methods
    //
    var methods = {
        init: function (options) {

            var defaults = {
                validator: function ($formEle) {
                    return true;
                }
            };

            options = $.extend(defaults, options);

            return this.each(function () {

                var $this = $(this),
                    data = $this.data('nestedForms');

                // If the plugin hasn't been initialized yet, store the options and the form attributes (null means the attr wont be used)
                if (!data) {
                    data = {
                        options: options,
                        acceptCharset: $this.data('acceptCharset') || null,
                        action: $this.data('action') || null,
                        enctype: $this.data('enctype') || null,
                        method: $this.data('method') || null,
                        name: $this.data('name') || null,
                        novalidate: $this.data('novalidate') || null,
                        target: $this.data('target') || null
                    };
                    $(this).data('nestedForms', data);
                }

                //disable enter key on input boxes within pseudo form, call custom submit.
                $this.children('input').on('keypress', function (e) {
                    if ((e.which == 13) || (event.keyCode == 10) || (event.keyCode == 13)) {
                        e.preventDefault();
                        //submit form
                        submitForm($this, data);
                        return false;
                    }
                });

                //capture submit button click.
                $this.children("input[type='submit'], button[type='submit']").on('click', function (e) {
                    e.preventDefault();
                    submitForm($this, data);
                    return false;
                });

            });
        },
        _debug: function () { }
    };


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // JQuery Plugin Core
    //
    $.fn.nestedForms = function (method) {

        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.nestedForms');
        }

    };

})(jQuery);


$(function() {
    //init the plugin for any data-target form objects.
    $("div[data-toggle='form']").nestedForms({});
});
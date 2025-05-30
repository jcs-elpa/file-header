[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![JCS-ELPA](https://raw.githubusercontent.com/jcs-emacs/badges/master/elpa/v/file-header.svg)](https://jcs-emacs.github.io/jcs-elpa/#/file-header)

# file-header
> Highly customizable self-design file header.

[![CI](https://github.com/jcs-elpa/file-header/actions/workflows/test.yml/badge.svg)](https://github.com/jcs-elpa/file-header/actions/workflows/test.yml)

## 🔧 Usage

### 🔍 Step 1. Define template path

First, you need to set the template config file path.

```elisp
(setq file-header-template-config-filepath "~/.emacs.jcs/template/template_config.properties")
```

### 🔍 Step 2. Create configuration

Then create the config file to the directory where you just set it. The config file 
the example can be found under `Config Example` section below.

### 🔍 Step 3. Design your template configuration

Create the template file and design it. The template file example can be found under 
`Templates Example` section below.

### 🔍 Step 4. Call and use it!

Lastly, you can define your own insert template function by calling `file-header-insert-template-by-file-path` 
bypassing the template file path.

Example function that insert the Java template. You can either set 
interactive or not interactive depends on your usage.

```elisp
(defun insert-java-template ()
  "Insert the template for Java file."
  (interactive)
  (file-header-insert-template-by-file-path "~/.emacs.d/template/java/java_template.txt"))
```

You can bind it to any `mode-hook' so every time you created a file, 
the template will be inserted.

```elisp
(add-hook 'java-mode-hook
              (lambda ()
                ;; Insert the template once a .java file created.
                (insert-java-template))
```

### 🖼️ Screenshot

Here is the result after I created `cool.java` file.

<img src="./etc/demo.png" width="612" height="255"/>

## 🧪 Config Example

Here is the minimal config example. Functions below like `(buffer-file-name)`, `(format-time-string "%Y")`, etc, 
are for demonstration purposes and not included inside this package. You would need 
to define these functions on your own somewhere in your emacs configuration.

```ini
# Author related
CREATOR_NAME=`user-full-name`

# File related
FILE_NAME=`buffer-file-name`
FILE_NAME_NO_EXT=`(file-name-sans-extension buffer-file-name)`

# Time
TIME_STAMP=`(format-time-string "%Y-%m-%d %H:%M:%S")`
TIME_YEAR=`(format-time-string "%Y")`
```

There are two ways to assign value in the config file.

* Assign property with value directly. e.g. `CREATOR_NAME=Jen-Chieh Shen`.
* Assign property to a lisp function that returns a string. e.g. ``TIME_STAMP=`(format-time-string "%Y-%m-%d %H:%M:%S")` ``.

## 🏚️ Templates Example

This is the minimal template example for a Java file. The full example 
can be found [here](https://github.com/jcs090218/jcs-emacs-init/tree/master/.emacs.jcs/template).

```java
/**
 * $File: #FILE_NAME# $
 * $Date: #TIME_STAMP# $
 * $Revision: $
 * $Creator: #CREATOR_NAME# $
 * $Notice: See LICENSE.txt for modification and distribution information
 *                   Copyright © #TIME_YEAR# by #COPYRIGHT_INFO# $
 */


public class #FILE_NAME_NO_EXT# {

}
```

## ️🛠 Contribute

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Elisp styleguide](https://img.shields.io/badge/elisp-style%20guide-purple)](https://github.com/bbatsov/emacs-lisp-style-guide)
[![Donate on paypal](https://img.shields.io/badge/paypal-donate-1?logo=paypal&color=blue)](https://www.paypal.me/jcs090218)
[![Become a patron](https://img.shields.io/badge/patreon-become%20a%20patron-orange.svg?logo=patreon)](https://www.patreon.com/jcs090218)

If you would like to contribute to this project, you may either 
clone or make pull requests to this repository. Or you can 
clone the project and establish your own branch of this tool. 
Any methods are welcome!

### 🔬 Development

To run the test locally, you will need the following tools:

- [Eask](https://emacs-eask.github.io/)
- [Make](https://www.gnu.org/software/make/) (optional)

Install all dependencies and development dependencies:

```sh
eask install-deps --dev
```

To test the package's installation:

```sh
eask package
eask install
```

To test compilation:

```sh
eask compile
```

**🪧 The following steps are optional, but we recommend you follow these lint results!**

The built-in `checkdoc` linter:

```sh
eask lint checkdoc
```

The standard `package` linter:

```sh
eask lint package
```

*📝 P.S. For more information, find the Eask manual at https://emacs-eask.github.io/.*

## ⚜️ License

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

See [`LICENSE`](./LICENSE.txt) for details.

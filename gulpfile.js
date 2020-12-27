const gulp = require("gulp");
const debug = require("gulp-debug");
const cleancss = require("gulp-clean-css");
const uglify = require("gulp-uglify");
const htmlmin = require('gulp-html-minifier-terser');
const htmlclean = require("gulp-htmlclean");
const imagemin = require("gulp-imagemin");
const changed = require("gulp-changed");
const gulpif = require("gulp-if");
const plumber = require("gulp-plumber");
const gulpBabel = require("gulp-babel");
const del = require("del");
const Hexo = require("hexo");
const hexo = new Hexo(process.cwd(), {});

const isScriptAll = true;
const isDebug = true;

function updateHexoConfig(hexo) {
    const regex = /\$(?:(\w+)|{(\w+)})/g;
    let strContent = JSON.stringify(hexo.config);

    strContent = strContent.replace(regex, (original, g1, g2) => {
        const variable = g1 || g2;

        return process.env.hasOwnProperty(variable)
            ? process.env[variable]
            : "";
    });

    hexo.config = JSON.parse(strContent);
}

gulp.task("clean", () => {
    return del(["public/**/*", 'db.json', ".deploy_git/"]);
});

gulp.task("generate", () => {
    return hexo.init().then(() => {
        updateHexoConfig(hexo);
        return hexo
            .call("generate", {
                watch: false
            })
            .then(() => {
                return hexo.exit();
            })
            .catch((err) => {
                return hexo.exit(err);
            });
    });
});

gulp.task("server", () => {
    return hexo.init().then(() => {
        updateHexoConfig(hexo);
        return hexo
            .call("server", {
                watch: true
            })
            .catch((err) => {
                console.log(err);
            });
    });
});

gulp.task("deploy", () => {
    return hexo.init().then(() => {
        updateHexoConfig(hexo);
        return hexo
            .call("deploy", {
                watch: false
            })
            .then(function () {
                return hexo.exit();
            })
            .catch(function (err) {
                return hexo.exit(err);
            });
    });
});

gulp.task("compressJs", () => {
    return gulp
        .src(["./public/**/*.js", "!./public/lib/**"])
        .pipe(gulpif(!isScriptAll, changed("./public")))
        .pipe(gulpif(isDebug, debug({title: "Compress JS:"})))
        .pipe(plumber())
        .pipe(
            gulpBabel({
                presets: ['@babel/preset-env']
            })
        )
        .pipe(uglify())
        .pipe(gulp.dest("./public"));
});

gulp.task("compressCss", () => {
    const option = {
        rebase: false,
        //advanced: true,
        compatibility: "ie7"
        //keepBreaks: true,
        //keepSpecialComments: '*'
    };

    return gulp
        .src(["./public/**/*.css", "!./public/**/*.min.css"])
        .pipe(gulpif(!isScriptAll, changed("./public")))
        .pipe(gulpif(isDebug, debug({title: "Compress CSS:"})))
        .pipe(plumber())
        .pipe(cleancss(option))
        .pipe(gulp.dest("./public"));
});

gulp.task("compressHtml", () => {
    const cleanOptions = {
        protect: /<\!--%fooTemplate\b.*?%-->/g,
        unprotect: /<script [^>]*\btype="text\/x-handlebars-template"[\s\S]+?<\/script>/gi
    };
    const minOption = {
        collapseWhitespace: true,
        collapseBooleanAttributes: true,
        removeEmptyAttributes: true,
        removeScriptTypeAttributes: true,
        removeStyleLinkTypeAttributes: true,
        removeComments: true,
        minifyJS: true,
        minifyCSS: true,
        minifyURLs: true
    };

    return gulp
        .src("./public/**/*.html")
        .pipe(gulpif(isDebug, debug({title: "Compress HTML:"})))
        .pipe(plumber())
        .pipe(htmlmin(minOption))
        .pipe(htmlclean(cleanOptions))
        .pipe(gulp.dest("./public"));
});

gulp.task("compressXml", () => {
    return gulp
        .src("./public/**/*.xml")
        .pipe(gulpif(isDebug, debug({title: "Compress XML:"})))
        .pipe(plumber())
        .pipe(htmlmin({collapseWhitespace: true}))
        .pipe(gulp.dest("./public"));
});

gulp.task("compressImage", () => {
    const option = {
        optimizationLevel: 5,
        progressive: true,
        interlaced: true,
        multipass: true
    };

    return gulp
        .src("./public/{medias,images}/**/*.*")
        .pipe(gulpif(!isScriptAll, changed("./public")))
        .pipe(gulpif(isDebug, debug({title: "Compress Images:"})))
        .pipe(plumber())
        .pipe(imagemin(option))
        .pipe(gulp.dest("./public/"));
});

gulp.task(
    "deploy",
    gulp.series(
        "clean",
        "generate",
        "compressHtml",
        "compressXml",
        "compressCss",
        "compressJs",
        "compressImage",
        "deploy"
    )
);

gulp.task(
    "default",
    gulp.series(
        "clean",
        "generate",
        gulp.parallel("compressHtml", "compressXml", "compressCss", "compressImage", "compressJs")
    )
);

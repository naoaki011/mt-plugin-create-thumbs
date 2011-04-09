package CreateThumbs::Plugin;

use strict;
use MT;
use MT::Image;
use MT::Template::Context;
use MT::Util qw(format_ts decode_html);

sub find_images {
	my ($ctx, $args, $cond) = @_;
	my $builder = $ctx->stash('builder');
	my $tokens = $ctx->stash('tokens');
	my $blog = MT::Blog->load( $ctx->stash('blog')->id );
	my $res;
	my $photodir = $args->{path};
	if (! -e $photodir){
		doLog($photodir . ' is not exist.');
	}
	else {
		if (! -d $photodir){
			doLog($photodir . ' is not directory.');
		}
		else {
			opendir( THISDIR, $photodir ) || die "Cannot open directory $photodir: $1";
			my @allfiles = grep( !/^\.\.?$/, readdir( THISDIR ) );
			closedir( THISDIR );
			my $exclude = $args->{exclude};
			if ( $exclude ne '' ) {
				@allfiles = grep( !/^.*$exclude.*$/, @allfiles );
			}
			my $photofile;
			my $ext = $args->{extension};
			my @usefiles;
			foreach $photofile ( @allfiles ) {
				if ( $photofile =~ /^(.+)\.($ext)$/ ) {
#					doLog( File::Spec->catfile( $photodir, $photofile ) );
					push( @usefiles, "$photofile" );
				}
			}
			my @sortedfiles;
			my $sort = $args->{sort_order};
			if ( $sort eq 'ascend' ) {
				@sortedfiles = sort @usefiles;
			}
			else {
				@sortedfiles = reverse sort @usefiles;
			}
			my $filename;
			foreach $filename ( @sortedfiles ) {
				my $out;
				$ctx->stash( 'ImageName', "$filename" );
				my $filepath;
				$filepath = $photodir . '/' . $filename;
				$filepath =~ s/\/\//\//g;
				$ctx->stash( 'ImagePath', "$filepath" );
				my($basename, $basepath, $ext) = File::Basename::fileparse($filepath, '\..*');
				$ctx->stash( 'BasePath', "$basepath" );
				$ctx->stash( 'ImageBasename', "$basename" );
				$ctx->stash( 'ImageExt', "$ext" );
				my $img_type;
				if ($ext =~ m/^\.gif$/i) {
					$img_type = 'gif';
				} elsif ($ext =~ m/^\.(jpg)|(jpeg)$/i) {
					$img_type = 'jpeg';
				} elsif ($ext =~ m/^\.png$/i) {
					$img_type = 'png';
				}
				my $img = MT::Image->new( Filename => $filepath,
											Type => $img_type )
					or return $ctx->error("Reading '$filepath' failed: ". MT::Image->errstr);
				$ctx->stash( 'ImageFile', $img );

				$out = $builder->build( $ctx, $tokens )
				  or return $ctx->error( $builder->errstr );
				$res .= $out;
			}
		}
	}
    return $res;
}

sub load_image {
	my ($ctx, $args, $cond) = @_;
	my $builder = $ctx->stash('builder');
	my $tokens = $ctx->stash('tokens');
	my $blog = MT::Blog->load( $ctx->stash('blog')->id );
	my $res;
	my $photodir = $args->{path};
	if (! -e $photodir){
		doLog($photodir . ' is not exist.');
	}
	else {
		if (! -d $photodir){
			doLog($photodir . ' is not directory.');
		}
		else {
			opendir( THISDIR, $photodir ) || die "Cannot open directory $photodir: $1";
			my @allfiles = grep( !/^\.\.?$/, readdir( THISDIR ) );
			closedir( THISDIR );
			my $exclude = $args->{exclude};
			if ( $exclude ne '' ) {
				@allfiles = grep( !/^.*$exclude.*$/, @allfiles );
			}
			my $photofile;
			my $ext = $args->{extension};
			my @usefiles;
			foreach $photofile ( @allfiles ) {
				if ( $photofile =~ /^(.+)\.($ext)$/ ) {
#					doLog( File::Spec->catfile( $photodir, $photofile ) );
					push( @usefiles, "$photofile" );
				}
			}
			my @sortedfiles;
			my $sort = $args->{sort_order};
			if ( $sort eq 'ascend' ) {
				@sortedfiles = sort @usefiles;
			}
			else {
				@sortedfiles = reverse sort @usefiles;
			}
			my $filename;
			foreach $filename ( @sortedfiles ) {
				my $out;
				$ctx->stash( 'ImageName', "$filename" );
				my $filepath;
				$filepath = $photodir . '/' . $filename;
				$filepath =~ s/\/\//\//g;
				$ctx->stash( 'ImagePath', "$filepath" );
				my($basename, $basepath, $ext) = File::Basename::fileparse($filepath, '\..*');
				$ctx->stash( 'BasePath', "$basepath" );
				$ctx->stash( 'ImageBasename', "$basename" );
				$ctx->stash( 'ImageExt', "$ext" );
				my $img_type;
				if ($ext =~ m/^\.gif$/i) {
					$img_type = 'gif';
				} elsif ($ext =~ m/^\.(jpg)|(jpeg)$/i) {
					$img_type = 'jpeg';
				} elsif ($ext =~ m/^\.png$/i) {
					$img_type = 'png';
				}
				my $img = MT::Image->new( Filename => $filepath,
											Type => $img_type )
					or return $ctx->error("Reading '$filepath' failed: ". MT::Image->errstr);
				$ctx->stash( 'ImageFile', $img );

				$out = $builder->build( $ctx, $tokens )
				  or return $ctx->error( $builder->errstr );
				$res .= $out;
			}
		}
	}
    return $res;
}

sub image_url {
	my ($ctx, $args) = @_;
	my $blog = MT::Blog->load( $ctx->stash('blog')->id );
	my $website = MT::Blog->load( $blog->parent_id ) ? MT::Blog->load( $blog->parent_id ) : $blog;
	my $site_path = $website->site_path;
	my $site_url = $website->site_url;
	my $fileurl = $ctx->stash('ImagePath');
	$fileurl =~ s|$site_path|$site_url|;
	$fileurl =~ s|([^:]/)/|$1|g;
	return $fileurl;
}

sub image_path {
	my ($ctx, $args) = @_;
	my $path = $ctx->stash('ImagePath');
	return $path;
}

sub base_path {
	my ($ctx, $args) = @_;
	my $basepath = $ctx->stash('BasePath');
	return $basepath;
}

sub image_name {
	my ($ctx, $args) = @_;
	my $name = $ctx->stash('ImageName');
	return $name;
}

sub image_basename {
	my ($ctx, $args) = @_;
	my $basename = $ctx->stash('ImageBasename');
	return $basename;
}

sub image_ext {
	my ($ctx, $args) = @_;
	my $ext = $ctx->stash('ImageExt');
	return $ext;
}

sub image_width {
	my ($ctx, $args) = @_;
	my $width = $ctx->stash('ImageFile')->{width};
	return $width;
}

sub image_height {
	my ($ctx, $args) = @_;
	my $height = $ctx->stash('ImageFile')->{height};
	return $height;
}

sub create_thumb {
	my ($ctx, $args, $cond) = @_;
	my $builder = $ctx->stash('builder');
	my $tokens = $ctx->stash('tokens');
	my $blog = MT::Blog->load( $ctx->stash('blog')->id );
	my $fmgr = $blog->file_mgr;

	my $thumb_filename = $ctx->stash('ImageBasename') . $args->{suffix} . $ctx->stash('ImageExt');
	$ctx->stash( 'ThumbFilename', "$thumb_filename" );

	my $thumb_basepath = $args->{base};
	$ctx->stash( 'ThumbBasePath', "$thumb_basepath" );
	if (! $fmgr->exists($thumb_basepath) ) {
		$fmgr->mkpath($thumb_basepath);
	}

	my $thumb_filepath = File::Spec->catfile($thumb_basepath, $thumb_filename);
	$ctx->stash( 'ThumbFilePath', "$thumb_filepath" );

	my $img = $ctx->stash('ImageFile');
	my $thumb_width = $args->{width};
	my ($blob, $t_width, $t_height) = $img->scale( Width => $thumb_width )
	  or return $ctx->error("Thumbnail failed: " . $img->errstr);
	$fmgr->put_data($blob, $thumb_filepath, 'upload')
	  or return $ctx->error("Error writing to '$thumb_filepath': " .
	  $fmgr->errstr);
	$ctx->stash( 'ThumbFile', $img );

	my $res = $builder->build( $ctx, $tokens )
	  or return $ctx->error( $builder->errstr );
    return $res;
}

sub thumb_url {
	my ($ctx, $args) = @_;
	my $blog = MT::Blog->load( $ctx->stash('blog')->id );
	my $website = MT::Blog->load( $blog->parent_id ) ? MT::Blog->load( $blog->parent_id ) : $blog;
	my $site_path = $website->site_path;
	my $site_url = $website->site_url;
	my $fileurl = $ctx->stash('ThumbFilePath');
	$fileurl =~ s/\\/\//g;
	$fileurl =~ s|$site_path|$site_url|;
	$fileurl =~ s|([^:]/)/|$1|g;
	return $fileurl;
}

sub thumb_path {
	my ($ctx, $args) = @_;
	my $filepath = $ctx->stash('ThumbFilePath');
	$filepath =~ s/\\/\//g;
	return $filepath;
}

sub thumb_image_name {
	my ($ctx, $args) = @_;
	my $filename = $ctx->stash('ThumbFilename');
	return $filename;
}

sub thumb_base_path {
	my ($ctx, $args) = @_;
	my $basepath = $ctx->stash('ThumbBasePath');
	return $basepath;
}

sub thumb_image_width {
	my ($ctx, $args) = @_;
	my $width = $ctx->stash('ThumbFile')->{width};
	return $width;
}

sub thumb_image_height {
	my ($ctx, $args) = @_;
	my $height = $ctx->stash('ThumbFile')->{height};
	return $height;
}

sub doLog {
    my ($msg) = @_; 
    return unless defined($msg);
    require MT::Log;
    my $log = MT::Log->new;
    $log->message($msg) ;
    $log->save or die $log->errstr;
}

1;

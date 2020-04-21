requires 'perl', '5.010000';
requires 'Alien::Build', '==2.17';
requires 'Alien::Libxml2', '==0.15';
requires 'XML::LibXML';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Slow', '0.04';
};


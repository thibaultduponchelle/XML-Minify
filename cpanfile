requires 'perl', '5.010000';
requires 'XML::LibXML', '==2.0203';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Slow', '0.04';
};


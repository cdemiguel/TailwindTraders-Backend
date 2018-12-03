﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Tailwind.Traders.ImageClassifier.Api.Mlnet
{
    public struct ImageNetSettings
    {
        public const int imageHeight = 227;
        public const int imageWidth = 227;
        public const float mean = 117;         //
        public const bool channelsLast = true; //
    }
}

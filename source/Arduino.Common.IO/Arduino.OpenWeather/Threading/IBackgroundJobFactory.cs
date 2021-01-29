// Copyright (c) 2021 Konstantellos Panagiotis, Zorbas Achileas. All rights reserved.
// Licensed under the GNU General Public License v3.0 or later. See LICENSE.md in the project root for license information.

namespace Arduino.OpenWeather.Threading
{
    public interface IBackgroundJobFactory
    {
        IBackgroundJob Create<T>(string options)
            where T : IBackgroundJob;
    }
}